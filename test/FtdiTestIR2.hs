{-# LANGUAGE FlexibleContexts #-}

import qualified Data.ByteString as B
import qualified Data.Text       as T
import           JtagRW          (UsbBlasterState, flush, fromBits, printState,
                                  toBits, vdrWrite, vdrWriteRead, virAddrOff,
                                  virAddrRead, virAddrWrite, virWrite,
                                  withUSBBlaster)
import           Protolude


-- FOR ./FPGA_CODE/JTAG_RW
vdrWidth :: Int
vdrWidth = 7

outLed :: Word8 -> (StateT UsbBlasterState) IO (Maybe ByteString)
outLed v = do
  _ <- virWrite virAddrWrite
  _ <- vdrWrite $ toBits vdrWidth v
  _ <- virWrite virAddrOff
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
