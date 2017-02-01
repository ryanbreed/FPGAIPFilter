{-# LANGUAGE FlexibleContexts #-}

import qualified Data.Text as T
import           JtagRW    (tapReset, toBits, virWrite, vdrWriteRead)
import           LibFtdi   (DeviceHandle, ftdiDeInit, ftdiInit, ftdiUSBClose,
                            ftdiUSBOpen, ftdiUSBReset, withFtdi)
import           Protolude

-- FOR: DE0_Nano_project_JTAG.qar

-- Derived from https://github.com/GeezerGeek/open_sld/blob/master/sld_interface.py,
-- And: http://sourceforge.net/p/ixo-jtag/code/HEAD/tree/usb_jtag/

-- Load the initialTest.sof from open_sld on the board and run... ;-)
-- The initial test wires the DS0-Nano LED bank up to the SLD and prints last VDR

outLed :: DeviceHandle -> Word32 -> IO Int
outLed d v = do
  l <- virWrite d 1 -- On
  (l1, rd) <- vdrWriteRead d $ toBits 7 v
  l2 <- virWrite d 0 -- Off
  print rd
  threadDelay 20000
  return $ l + l1 + l2

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
