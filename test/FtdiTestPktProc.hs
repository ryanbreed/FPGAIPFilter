{-# LANGUAGE FlexibleContexts #-}

import qualified Data.Text as T
import           JtagRW    (tapReset, toBits, fromBits, vdrWrite, vdrWriteRead,
                            virAddrOff, virAddrRead, virAddrWrite, virWrite)
import           LibFtdi   (DeviceHandle, ftdiDeInit, ftdiInit, ftdiUSBClose,
                            ftdiUSBOpen, ftdiUSBReset, withFtdi)
import           Protolude

-- FOR ./FPGA_CODE/JTAG_RW
vdrWidth :: Int
vdrWidth = 12
writeFlag :: Word16
writeFlag = 2 ^ (vdrWidth - 1)
readMask :: Word16
readMask = 2 ^ (vdrWidth - 1) - 1

readVdr :: DeviceHandle -> IO (Int, [Bool])
readVdr d  = do
  l3 <- virWrite d virAddrRead
  (l4, rd) <- vdrWriteRead d $ toBits vdrWidth (0 :: Word8)
  return (l3 + l4, rd)

outWrite :: DeviceHandle -> Word8 -> IO Int
outWrite d v = do
  l0 <- virWrite d virAddrWrite
  l1 <- vdrWrite d $ toBits vdrWidth (fromIntegral v  * 8 + writeFlag)
  (l4, rd) <- readVdr d
  l5 <- virWrite d virAddrOff
  putStrLn $ "W:" ++ show (fromIntegral v  * 8 + writeFlag) ++ ", " ++ show (fromBits rd)
  -- threadDelay 20000
  return $ l0 + l1 + l4 + l5

outRead :: DeviceHandle -> Word16 -> IO Int
outRead d a = do
  l0 <- virWrite d virAddrWrite
  l1 <- vdrWrite d $ toBits vdrWidth (a .&. readMask)
  (l4, rd) <- readVdr d
  l5 <- virWrite d virAddrOff
  let r = fromBits rd
  putStrLn $ "R:" ++ show (a .&. readMask) ++ ", "
                  ++ show r ++ ", "
                  ++ show (r `div` 8 .&. 255) ++ ", "
                  ++ show (r .&. 7)
  -- threadDelay 20000
  return $ l0 + l1 + l4 + l5

doStuff :: DeviceHandle -> IO ()
doStuff d = do
  ftdiUSBOpen d (0x09fb, 0x6001)
  ftdiUSBReset d
  _ <- mapM (outWrite d) $ join $ replicate 2 [0..255]
  _ <- mapM (outRead d)  [0..2047]
  putStrLn ("Init OK." :: Text)
  ftdiUSBClose d
  ftdiDeInit d

main :: IO ()
main = do
    dh <- ftdiInit
    case dh of
      Left err -> putStrLn $ T.pack $ "Error:" ++ show err
      Right _ -> withFtdi doStuff
