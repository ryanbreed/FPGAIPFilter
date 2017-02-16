{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}

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
-- import           Bytestring as B

-- FOR ./FPGA_CODE/JTAG_RW_PKT_PROC
vdrWidth :: Int
vdrWidth = 12
writeFlag :: Word16
writeFlag = 2 ^ (vdrWidth - 1)
readMask :: Word16
readMask = 2 ^ (vdrWidth - 1) - 1

readVdr :: (StateT UsbBlasterState) IO (Maybe [Bool])
readVdr = do
  _ <- virWrite virAddrRead
  _ <- vdrWriteRead $ toBits vdrWidth (0::Word32)
  flush

outWrite :: Word8 -> (StateT UsbBlasterState) IO (Maybe ByteString)
outWrite v = do
  _ <- virWrite virAddrWrite
  _ <- vdrWrite $ toBits vdrWidth (fromIntegral v  * 8 + writeFlag)
  _ <- virWrite virAddrOff
  _ <- flush
  putStrLn $ "W:" ++ show (fromIntegral v  * 8 + writeFlag)
  return $ Just "todo"

outRead :: Word16 -> (StateT UsbBlasterState) IO (Maybe Int)
outRead a = do
  _ <- virWrite virAddrWrite
  _ <- vdrWrite $ toBits vdrWidth (a .&. readMask)
  _ <- flush
  rd <- readVdr
  _ <- flush
  _ <- virWrite virAddrOff
  let rn = fromBits . reverse <$> rd
  case rn of
    Just r -> putStrLn $ "R:" ++ show (a .&. readMask) ++ ", "
                  ++ show r ++ ", "
                  ++ show (r `div` 8 .&. 255) ++ ", "
                  ++ show (r .&. 7)
    Nothing -> putStrLn ("Error nothing read"::Text)
  pure rn

doStuff :: (StateT UsbBlasterState) IO (Maybe B.ByteString)
doStuff = do
  _ <- mapM outWrite $ join $ replicate 2 [0..255]
  _ <- mapM outRead [0..2047]
  return Nothing

-- virAddrBase :: Word16
-- virAddrBase = 0x400 -- for one ram 0x100 -- for one hub jtag = 0x10
--
-- irAddrLen, virAddrLen :: Int
-- irAddrLen  = 10
-- virAddrLen = 12 -- for one ram 10 -- for one hub jtag instance = 5
main :: IO ()
main = do
    dh <- withUSBBlaster 0x400 10 12 doStuff
    case dh of
      Just err -> putStrLn $ T.pack $ "Error:" ++ show err
      Nothing -> pure ()
