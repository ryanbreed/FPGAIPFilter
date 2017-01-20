{-# LANGUAGE FlexibleContexts #-}

import qualified Data.Text as T
import qualified Data.ByteString as B
import           LibFtdi   (DeviceHandle, ftdiDeInit, ftdiInit, ftdiUSBClose,
                            ftdiUSBOpen, ftdiUSBReset, withFtdi, ftdiWriteData)
import           Protolude

-- Derived from https://github.com/GeezerGeek/open_sld/blob/master/sld_interface.py,
-- And: http://sourceforge.net/p/ixo-jtag/code/HEAD/tree/usb_jtag/

-- Load the initialTest.sof from open_sld and run... ;-)

-- @TODO add Read

jtagOFF, jtagTCK, jtagTMS, jtagTDI, jtagLED, jtagRD, jtagSHM :: Word8
jtagOFF = 0x00
jtagTCK = 0x01
jtagTMS = 0x02
jtagTDI = 0x10
jtagLED = 0x20
jtagRD  = 0x40
jtagSHM = 0x80

jtagM0D0R, jtagM0D1R, jtagM1D0R, jtagM1D1R :: [Word8]
-- Bit-mode - Two byte codes
jtagM0D0R = [ jtagLED                         .|. jtagRD,
              jtagLED                         .|. jtagTCK
            ]
jtagM0D1R = [ jtagLED .|. jtagTDI             .|. jtagRD,
              jtagLED             .|. jtagTDI .|. jtagTCK
            ]
jtagM1D0R = [ jtagLED .|. jtagTMS             .|. jtagRD,
              jtagLED .|. jtagTMS .|. jtagTCK
            ]
jtagM1D1R = [ jtagLED .|. jtagTMS .|. jtagTDI .|. jtagRD,
              jtagLED .|. jtagTMS .|. jtagTDI .|. jtagTCK
            ]

jtagM0D0, jtagM0D1, jtagM1D0, jtagM1D1 :: [Word8]
jtagM0D0 = [ jtagLED                         ,
             jtagLED                         .|. jtagTCK
           ]
jtagM0D1 = [ jtagLED .|. jtagTDI             ,
             jtagLED             .|. jtagTDI .|. jtagTCK
           ]
jtagM1D0 = [ jtagLED .|. jtagTMS             ,
             jtagLED .|. jtagTMS             .|. jtagTCK
           ]
jtagM1D1 = [ jtagLED .|. jtagTMS .|. jtagTDI ,
             jtagLED .|. jtagTMS .|. jtagTDI .|. jtagTCK
           ]

-- TAP controller Reset
jtagTAP_RESET :: [Word8]
jtagTAP_RESET = jtagM1D0 ++ jtagM1D0 ++ jtagM1D0 ++ jtagM1D0 ++ jtagM1D0

-- TAP controller Reset to Idle
jtagTAP_IDLE :: [Word8]
jtagTAP_IDLE = jtagM0D0

-- TAP controller Idle to Shift_DR
jtagTAP_SHIFT_DR :: [Word8]
jtagTAP_SHIFT_DR = jtagM1D0 ++ jtagM0D0 ++ jtagM0D0

-- TAP controller Idle to Shift_IR
jtagTAP_SHIFT_IR :: [Word8]
jtagTAP_SHIFT_IR = jtagM1D0 ++ jtagM1D0 ++ jtagM0D0 ++ jtagM0D0

-- TAP controller Exit1 to Idle
jtagTAP_END_SHIFT :: [Word8]
jtagTAP_END_SHIFT = jtagM1D0 ++ jtagM0D0

-- IR values
jtagSELECT_VIR :: [Word8]
jtagSELECT_VIR = jtagM0D0 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D0 ++
                 jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D0

jtagSELECT_VDR :: [Word8]
jtagSELECT_VDR = jtagM0D0 ++ jtagM0D0 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D0 ++
                 jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D0

jtagNODE_SHIFT_INST :: [Word8]
jtagNODE_SHIFT_INST  = jtagM0D1 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D1

jtagNODE_UPDATE_INST :: [Word8]
jtagNODE_UPDATE_INST = jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D1

-- Node Data
jtagNODE_DATA :: [Word8]
jtagNODE_DATA = jtagM0D0 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D0 ++ jtagM0D0 ++
                jtagM0D1 ++ jtagM1D1

revSplitMsb::[Bool] -> Maybe (Bool, [Bool])
revSplitMsb [] = Nothing
revSplitMsb (x:xs) = Just (x, reverse xs)

mkBytesJtag :: Maybe (Bool, [Bool]) -> [Word8] -> [Word8] -> [Word8] -> [Word8] -> [Word8]
mkBytesJtag msbBits v0 v1 vm0 vm1 =
  case msbBits of
    Nothing -> []
    Just (msb, bits) ->
      join (fmap (\v -> if v then v1 else v0) bits) ++ if msb then vm1 else vm0

jtagWriteBits::DeviceHandle -> [Bool] -> IO Int
jtagWriteBits d bits = ftdiWriteData d $ B.pack $
      mkBytesJtag (revSplitMsb bits) jtagM0D0 jtagM0D1 jtagM1D0 jtagM1D1

tapReset::DeviceHandle -> IO Int
tapReset d = ftdiWriteData d $ B.pack $ jtagTAP_RESET ++ jtagTAP_IDLE

toBits :: Int -> Word32 -> [Bool]
toBits 0 _ = []
toBits 1 v = [v .&. 1 /= 0]
toBits s v = fmap (\b -> v .&. shift 1 b /= 0) [s - 1, s-2..0]

irWrite::DeviceHandle -> [Bool] -> IO Int
irWrite d b = do
  l <- ftdiWriteData d $ B.pack jtagTAP_SHIFT_IR
  l1 <- jtagWriteBits d b
  l2 <- ftdiWriteData d $ B.pack jtagTAP_END_SHIFT
  return $ l + l1 + l2

virWrite::DeviceHandle -> [Bool] -> IO Int
virWrite d b = do
  l <- irWrite d $ toBits 10 0xE
  l1 <- ftdiWriteData d $ B.pack jtagTAP_SHIFT_DR
  l2 <- jtagWriteBits d b
  l3 <- ftdiWriteData d $ B.pack jtagTAP_END_SHIFT
  return $ l + l1 + l2 + l3

vdrWrite::DeviceHandle -> [Bool] -> IO Int
vdrWrite d b = do
  l <- irWrite d $ toBits 10 0xC
  l1 <- ftdiWriteData d $ B.pack jtagTAP_SHIFT_DR
  l2 <- jtagWriteBits d b
  l3 <- ftdiWriteData d $ B.pack jtagTAP_END_SHIFT
  return $ l + l1 + l2 + l3

outLed :: DeviceHandle -> Word32 -> IO Int
outLed d v = do
  l <- virWrite d $ toBits 5 0x11
  l1 <- vdrWrite d $ toBits 7 v
  l2 <- virWrite d $ toBits 5 0x10
  threadDelay 40000
  return $ l + l1 + l2

doStuff :: DeviceHandle -> IO ()
doStuff d = do
  ftdiUSBOpen d (0x09fb, 0x6001)
  ftdiUSBReset d
  _ <- tapReset d
  _ <- mapM (outLed d) [0..127]
  putStrLn ("Init OK." :: Text)
  ftdiUSBClose d
  ftdiDeInit d

main :: IO ()
main = do
    dh <- ftdiInit
    case dh of
      Left err -> putStrLn $ T.pack $ "Error:" ++ show err
      Right _ -> withFtdi doStuff
