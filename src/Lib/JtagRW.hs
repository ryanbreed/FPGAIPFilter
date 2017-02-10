module Lib.JtagRW
(
  tapReset,
  virAddrWrite, virAddrRead, virAddrOff,
  virWrite, vdrWrite, vdrWriteRead,
  toBits, fromBits,
) where

import qualified Data.ByteString as B
import           LibFtdi         (DeviceHandle, ftdiReadData, ftdiWriteData)
import           Protolude

-- Derived from https://github.com/GeezerGeek/open_sld/blob/master/sld_interface.py,
-- And: http://sourceforge.net/p/ixo-jtag/code/HEAD/tree/usb_jtag/

jtagTCK, jtagTMS, jtagTDI, jtagLED, jtagRD :: Word8
--jtagOFF = 0x00
jtagTCK = 0x01
jtagTMS = 0x02
--jtagnCE = 0x04
--jtagnCS = 0x08
jtagTDI = 0x10
jtagLED = 0x20
jtagRD  = 0x40
--jtagSHM = 0x80

irAddrVir, irAddrVdr :: Word16
irAddrVir = 0x0E
irAddrVdr = 0x0C

virAddrBase :: Word16
virAddrBase = 0x400 -- for one ram 0x100 -- for one hub jtag = 0x10

irAddrLen, virAddrLen :: Int
irAddrLen  = 10
virAddrLen = 12 -- for one ram 10 -- for one hub jtag instance = 5

jtagM0D0R, jtagM0D1R, jtagM1D0R, jtagM1D1R :: [Word8]
-- Bit-mode - Two byte codes
jtagM0D0R = [ jtagLED                         .|. jtagRD
            , jtagLED                                     .|. jtagTCK
            ]
jtagM0D1R = [ jtagLED             .|. jtagTDI .|. jtagRD
            , jtagLED             .|. jtagTDI             .|. jtagTCK
            ]
jtagM1D0R = [ jtagLED .|. jtagTMS             .|. jtagRD
            , jtagLED .|. jtagTMS                         .|. jtagTCK
            ]
jtagM1D1R = [ jtagLED .|. jtagTMS .|. jtagTDI .|. jtagRD
            , jtagLED .|. jtagTMS .|. jtagTDI             .|. jtagTCK
            ]

jtagM0D0, jtagM0D1, jtagM1D0, jtagM1D1 :: [Word8]
jtagM0D0 = [ jtagLED
           , jtagLED                                      .|. jtagTCK
           ]
jtagM0D1 = [ jtagLED              .|. jtagTDI
           , jtagLED              .|. jtagTDI             .|. jtagTCK
           ]
jtagM1D0 = [ jtagLED .|. jtagTMS
           , jtagLED .|. jtagTMS                          .|. jtagTCK
           ]
jtagM1D1 = [ jtagLED .|. jtagTMS .|. jtagTDI
           , jtagLED .|. jtagTMS .|. jtagTDI              .|. jtagTCK
           ]

-- TAP controller Reset
tapResetSeq :: [Word8]
tapResetSeq = jtagM1D0 ++ jtagM1D0 ++ jtagM1D0 ++ jtagM1D0 ++ jtagM1D0

-- TAP controller Reset to Idle
tapIdleSeq :: [Word8]
tapIdleSeq = jtagM0D0

-- TAP controller Idle to Shift_DR
tapShiftVDRSeq :: [Word8]
tapShiftVDRSeq = jtagM1D0 ++ jtagM0D0 ++ jtagM0D0

-- TAP controller Idle to Shift_IR
tapShiftVIRSeq :: [Word8]
tapShiftVIRSeq = jtagM1D0 ++ jtagM1D0 ++ jtagM0D0 ++ jtagM0D0

-- TAP controller Exit1 to Idle
tapEndSeq :: [Word8]
tapEndSeq = jtagM1D0 ++ jtagM0D0

-- tapSelectVIRSeq :: [Word8]
-- tapSelectVIRSeq = jtagM0D0 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D0 ++
--                  jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D0
--
-- tapSelectVDRSeq :: [Word8]
-- jtagSELECT_VDR = jtagM0D0 ++ jtagM0D0 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D0 ++
--                  jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D0
--
-- tapNodeShiftInstSeq :: [Word8]
-- tapNodeShiftInstSeq  = jtagM0D1 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D1
--
-- tapNodeUpdateInstSeq :: [Word8]
-- tapNodeUpdateInstSeq = jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM0D0 ++ jtagM1D1
--
-- tapNodeDataSeq :: [Word8]
-- tapNodeDataSeq = jtagM0D0 ++ jtagM0D1 ++ jtagM0D1 ++ jtagM0D0 ++ jtagM0D0 ++
--                 jtagM0D1 ++ jtagM1D1

revSplitMsb::[Bool] -> Maybe (Bool, [Bool])
revSplitMsb [] = Nothing
revSplitMsb (x:xs) = Just (x, reverse xs)

mkBytesJtag :: Maybe (Bool, [Bool]) ->
                [Word8] -> [Word8] ->
                [Word8] -> [Word8] ->
                [Word8]
mkBytesJtag msbBits v0 v1 vm0 vm1 =
  case msbBits of
    Nothing -> []
    Just (msb, bits) ->
      join (fmap (\v -> if v then v1 else v0) bits) ++ if msb then vm1 else vm0

jtagWriteBits::DeviceHandle -> [Bool] -> IO Int
jtagWriteBits d bits = ftdiWriteData d $ B.pack $
      mkBytesJtag (revSplitMsb bits) jtagM0D0 jtagM0D1 jtagM1D0 jtagM1D1

lsbToBool :: [Word8] -> [Bool]
lsbToBool b = fmap (\v -> v .&. 1 /= 0) b

-- @todo cleanup
ftdiReadWithTimeout :: DeviceHandle -> B.ByteString -> Int -> Int -> Int ->
                      IO (Maybe B.ByteString)
ftdiReadWithTimeout d acc left iter delay =
   if iter == 0
      then pure Nothing
      else do
        rd <- ftdiReadData d left
        case rd of
          Nothing -> do
            threadDelay delay
            ftdiReadWithTimeout d acc left (iter - 1) delay
          Just r ->
            let newacc = acc `B.append` r
                newleft = left - B.length r in
                  if newleft == 0
                    then pure $ Just newacc
                    else do
                      threadDelay delay
                      ftdiReadWithTimeout d newacc newleft (iter - 1) delay

jtagWriteReadBits::DeviceHandle -> [Bool] -> IO (Int, [Bool])
jtagWriteReadBits d bits = do
  sz <- ftdiWriteData d $ B.pack $
          mkBytesJtag (revSplitMsb bits) jtagM0D0R jtagM0D1R jtagM1D0R jtagM1D1R
  rd <- ftdiReadWithTimeout d "" (length bits) 5 1000 -- @todo parameters
  case rd of
    Just r -> pure (sz, lsbToBool $ B.unpack r)
    _ -> pure (sz, [])

tapReset::DeviceHandle -> IO Int
tapReset d = ftdiWriteData d $ B.pack $ tapResetSeq ++ tapIdleSeq

toBits :: (Eq a, Num a, Bits a) => Int -> a -> [Bool]
toBits 0 _ = []
toBits 1 v = [v .&. 1 /= 0]
toBits s v = fmap (\b -> v .&. shift 1 b /= 0) [s - 1, s-2..0]

pwr2::[Int]
pwr2 = 1 : fmap (2*) pwr2

fromBits::[Bool] -> Int
fromBits [] = 0
fromBits x = foldr addPwr 0 $ zip x pwr2
  where addPwr (b,n) a = if b then a + n else a

irWrite::DeviceHandle -> [Bool] -> IO Int
irWrite d b = do
  l <- ftdiWriteData d $ B.pack tapShiftVIRSeq
  l1 <- jtagWriteBits d b
  l2 <- ftdiWriteData d $ B.pack tapEndSeq
  pure $ l + l1 + l2

virWrite::DeviceHandle -> Word8 -> IO Int
virWrite d addr = do
  -- @todo addr < virAddrBase
  l <- irWrite d $ toBits irAddrLen irAddrVir
  l1 <- ftdiWriteData d $ B.pack tapShiftVDRSeq
  l2 <- jtagWriteBits d $ toBits virAddrLen $ virAddrBase + fromIntegral addr
  l3 <- ftdiWriteData d $ B.pack tapEndSeq
  pure $ l + l1 + l2 + l3

vdrWrite::DeviceHandle -> [Bool] -> IO Int
vdrWrite d b = do
  l <- irWrite d $ toBits irAddrLen irAddrVdr
  l1 <- ftdiWriteData d $ B.pack tapShiftVDRSeq
  l2 <- jtagWriteBits d b
  l3 <- ftdiWriteData d $ B.pack tapEndSeq
  pure $ l + l1 + l2 + l3

vdrWriteRead::DeviceHandle -> [Bool] -> IO (Int, [Bool])
vdrWriteRead d b = do
  l <- irWrite d $ toBits irAddrLen irAddrVdr
  l1 <- ftdiWriteData d $ B.pack tapShiftVDRSeq
  (l2, r) <- jtagWriteReadBits d b
  l3 <- ftdiWriteData d $ B.pack tapEndSeq
  pure (l + l1 + l2 + l3, r)

virAddrWrite, virAddrRead, virAddrOff :: Word8
virAddrWrite = 0x02
virAddrRead  = 0x01
virAddrOff   = 0x00
