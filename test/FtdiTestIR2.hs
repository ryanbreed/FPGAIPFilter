{-# LANGUAGE FlexibleContexts #-}

import qualified Data.Text       as T
import           LibFtdi         (DeviceHandle, ftdiDeInit, ftdiInit,
                                  ftdiUSBClose, ftdiUSBOpen, ftdiUSBReset,
                                  withFtdi)
import           JtagRW ( tapReset,
                         virWrite, vdrWrite, vdrWriteRead,
                         virAddrWrite, virAddrRead, virAddrOff,
                         toBits,)
import           Protolude


-- FOR /home/jason/Develop/haskell/FPGAIPFilter_1/DE0_Nano_JTAG_RW.qar

outLed :: DeviceHandle -> Word32 -> IO Int
outLed d v = do
  l0 <- virWrite d virAddrWrite
  l1 <- vdrWrite d $ toBits 7 v
  l3 <- virWrite d virAddrRead
  (l4, rd) <- vdrWriteRead d $ toBits 7 (0 :: Word8)
  l5 <- virWrite d virAddrOff
  print rd
  threadDelay 20000
  return $ l0 + l1 + l3 + l4 + l5

doStuff :: DeviceHandle -> IO ()
doStuff d = do
  ftdiUSBOpen d (0x09fb, 0x6001)
  ftdiUSBReset d
  _ <- tapReset d
  _ <- mapM (outLed d) [0..127]
  _ <- mapM (outLed d) $ join $ replicate 16 [1, 2, 4, 8, 16, 32, 64, 32, 16, 8, 4, 2, 1]
  _ <- mapM (outLed d) [127,126..0]
  putStrLn ("Init OK." :: Text)
  ftdiUSBClose d
  ftdiDeInit d

main :: IO ()
main = do
    dh <- ftdiInit
    case dh of
      Left err -> putStrLn $ T.pack $ "Error:" ++ show err
      Right _ -> withFtdi doStuff
