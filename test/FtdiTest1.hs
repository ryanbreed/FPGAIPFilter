{-# LANGUAGE FlexibleContexts #-}

import qualified Data.Text as T
import qualified Data.ByteString as B
import           JtagRW     ( UsbBlasterState
                            , withUSBBlaster
                            , toBits, fromBits
                            , virWrite, vdrWrite, vdrWriteRead
                            , virAddrOff, virAddrRead, virAddrWrite
                            , flush
                            , printState
                            )
import           Protolude
--
-- FOR: DE0_Nano_project_JTAG.qar

-- Derived from https://github.com/GeezerGeek/open_sld/blob/master/sld_interface.py,
-- And: http://sourceforge.net/p/ixo-jtag/code/HEAD/tree/usb_jtag/

-- Load the initialTest.sof from open_sld on the board and run... ;-)
-- The initial test wires the DS0-Nano LED bank up to the SLD and prints last VDR

outLed :: Word8 -> (StateT UsbBlasterState) IO (Maybe ByteString)
outLed v = do
  _ <- virWrite 1
  _ <- vdrWrite $ toBits 5 v
  _ <- virWrite 0
  _ <- flush
  return $ Just "todo"

doStuff :: (StateT UsbBlasterState) IO (Maybe B.ByteString)
doStuff = do
  _ <- mapM outLed [0..127]
  _ <- mapM outLed $ join $ replicate 16 [1, 2, 4, 8, 16, 32, 64, 32, 16, 8, 4, 2, 1]
  _ <- mapM outLed [127,126..0]
  return Nothing

main :: IO ()
main = do
    dh <- withUSBBlaster 0x10 10 5 doStuff
    case dh of
      Just err -> putStrLn $ T.pack $ "Error:" ++ show err
      Nothing -> pure ()
