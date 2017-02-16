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
import           PacketProcessorDF
import           Protolude

-- FOR ./FPGA_CODE/JTAG_RW_PKT_PROC_MOORE
vdrWidth :: Int
vdrWidth = 53

memOpToBits:: (MemOp, Bool) -> Int
memOpToBits (mop, en) =
  case mop of -- 29 downto 0
    READ _     -> 0
    WRITE d    -> fromBits $ [en] ++ [False, True] ++ toBits 8 d ++ replicate 19 False
    SETP a m v -> fromBits $ [en] ++ [True, False] ++ toBits 11 a ++ toBits 8 m ++ toBits 8 v
    RESET      -> fromBits $ [en] ++ [True, True]  ++ replicate 27 False

    -- , std_logic_vector(output_0_0)  => vdr_in(52 downto 42)
    -- , std_logic_vector(output_0_1)  => vdr_in(41 downto 31)
    -- , std_logic_vector(output_0_2)  => vdr_in(30 downto 27)
    -- , std_logic_vector(output_0_3)  => vdr_in(26 downto 11)
    -- , std_logic_vector(output_0_4)  => vdr_in(10 downto 2)
    -- , to_stdulogic(output_0_5)      => vdr_in(1)
    -- , to_stdulogic(output_0_8)      => vdr_in(0)
data PPState = PPState
  { ppCounter :: Int
  , ppLeft :: Int
  , ppIhs :: Int
  , ppPktLen :: Int
  , ppLastData :: Maybe Int
  , ppDone :: Bool
  , ppMatch :: Bool
  } deriving (Show)

-- @todo more robust
toMaybeInt::Int -> Int -> Maybe Int
toMaybeInt s d =
  if d >= s
    then Just (d - s)
    else Nothing

bitsToState :: [Bool] -> Maybe PPState
bitsToState b =
  if length b /= vdrWidth
    then Nothing
    else
      let revb = reverse b
          counter'  = fromBits $ take 11           revb
          left'     = fromBits $ take 11 $ drop 11 revb
          ihs'      = fromBits $ take  4 $ drop 22 revb
          pktLen'   = fromBits $ take 16 $ drop 26 revb
          lastData' = toMaybeInt 256 $
                     fromBits $ take  9 $ drop 42 revb
          done'     = fromBits $ take  1 $ drop 51 revb
          match'    = fromBits $ take  1 $ drop 52 revb in
      Just $ PPState counter' left' ihs' pktLen' lastData' (done' /= 0) (match' /= 0)

readVdr :: (StateT UsbBlasterState) IO (Maybe [Bool])
readVdr = do
  _ <- virWrite virAddrRead
  _ <- vdrWriteRead $ toBits vdrWidth (0::Word64)
  flush

outWrite :: (MemOp, Bool) -> (StateT UsbBlasterState) IO (Maybe ByteString)
outWrite m = do
  let bits = toBits vdrWidth $ memOpToBits m
  _ <- virWrite virAddrWrite
  _ <- vdrWrite bits
  _ <- flush
  _ <- stateRead
  _ <- flush
  _ <- virWrite virAddrOff
  _ <- flush
  return $ Just "todo"

stateRead :: (StateT UsbBlasterState) IO (Maybe PPState)
stateRead  = do
  rd <- readVdr
  _ <- virWrite virAddrOff
  let rn = bitsToState <$> rd
  case rn of
    Just r -> putStrLn $ "R:" ++ show r  -- ++ ", " ++ show rd
    Nothing -> putStrLn ("Error nothing read"::Text)
  pure $ join rn

doStuff :: (StateT UsbBlasterState) IO (Maybe B.ByteString)
doStuff = do
  _ <- mapM outWrite pktBytes
  return Nothing

pktBytes::[(MemOp, Bool)]
pktBytes =
  [ (RESET, True)
  , (SETP 9 0xF0 0x10, True)
  , (WRITE 0x45, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, True)
  , (WRITE 0x70, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, True)
  , (WRITE 0x40, True)
  , (WRITE 0x00, True)
  , (WRITE 0x40, True)
  , (WRITE 0x11, True)
  , (WRITE 0x24, True)
  , (WRITE 0x3b, True)
  , (WRITE 0x0a, True)
  , (WRITE 0x01, True)
  , (WRITE 0x01, True)
  , (WRITE 0x0a, True)
  , (WRITE 0x0a, True)
  , (WRITE 0x01, True)
  , (WRITE 0x01, True)
  , (WRITE 0x37, True)
  , (WRITE 0x00, True)
  , (WRITE 0x35, True)
  , (WRITE 0x3e, True)
  , (WRITE 0x1a, True)
  , (WRITE 0x00, True)
  , (WRITE 0x5c, True)
  , (WRITE 0x65, True)
  , (WRITE 0xaa, True)
  , (WRITE 0x07, True)
  , (WRITE 0xec, True)
  , (WRITE 0x81, True)
  , (WRITE 0x80, True)
  , (WRITE 0x00, True)
  , (WRITE 0x01, True)
  , (WRITE 0x00, True)
  , (WRITE 0x01, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, True)
  , (WRITE 0x02, True)
  , (WRITE 0x32, True)
  , (WRITE 0x35, True)
  , (WRITE 0x03, True)
  , (WRITE 0x31, True)
  , (WRITE 0x35, True)
  , (WRITE 0x36, True)
  , (WRITE 0x03, True)
  , (WRITE 0x31, True)
  , (WRITE 0x37, True)
  , (WRITE 0x36, True)
  , (WRITE 0x03, True)
  , (WRITE 0x32, True)
  , (WRITE 0x31, True)
  , (WRITE 0x30, True)
  , (WRITE 0x07, True)
  , (WRITE 0x69, True)
  , (WRITE 0x6e, True)
  , (WRITE 0x2d, True)
  , (WRITE 0x61, True)
  , (WRITE 0x64, True)
  , (WRITE 0x64, True)
  , (WRITE 0x72, True)
  , (WRITE 0x04, True)
  , (WRITE 0x61, True)
  , (WRITE 0x72, True)
  , (WRITE 0x70, True)
  , (WRITE 0x61, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, True)
  , (WRITE 0x0c, True)
  , (WRITE 0x00, True)
  , (WRITE 0x01, True)
  , (WRITE 0xc0, True)
  , (WRITE 0x0c, True)
  , (WRITE 0x00, True)
  , (WRITE 0x0c, True)
  , (WRITE 0x00, True)
  , (WRITE 0x01, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, True)
  , (WRITE 0x89, True)
  , (WRITE 0x40, True)
  , (WRITE 0x00, True)
  , (WRITE 0x1b, True)
  , (WRITE 0x07, True)
  , (WRITE 0x75, True)
  , (WRITE 0x6e, True)
  , (WRITE 0x6b, True)
  , (WRITE 0x6e, True)
  , (WRITE 0x6f, True)
  , (WRITE 0x77, True)
  , (WRITE 0x6e, True)
  , (WRITE 0x0d, True)
  , (WRITE 0x74, True)
  , (WRITE 0x65, True)
  , (WRITE 0x6c, True)
  , (WRITE 0x73, True)
  , (WRITE 0x74, True)
  , (WRITE 0x72, True)
  , (WRITE 0x61, True)
  , (WRITE 0x67, True)
  , (WRITE 0x6c, True)
  , (WRITE 0x6f, True)
  , (WRITE 0x62, True)
  , (WRITE 0x61, True)
  , (WRITE 0x6c, True)
  , (WRITE 0x03, True)
  , (WRITE 0x6e, True)
  , (WRITE 0x65, True)
  , (WRITE 0x74, True)
  , (WRITE 0x00, True)
  , (WRITE 0x00, False)
  ]

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
