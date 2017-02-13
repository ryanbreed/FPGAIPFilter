{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module Lib.JtagRW
  ( UsbBlasterState
  , withUSBBlaster
  , virAddrWrite, virAddrRead, virAddrOff
  , virWrite, vdrWrite, vdrWriteRead
  , toBits, fromBits
  , flush
  , readInput
  , printState
  ) where

import           Protolude                 hiding (get)
import qualified Data.ByteString           as B
import           Control.Monad.Trans.State
import           Control.Lens
import           LibFtdi                   (DeviceHandle, ftdiDeInit, ftdiInit,
                                            ftdiReadData, ftdiUSBClose,
                                            ftdiUSBOpen, ftdiUSBReset,
                                            ftdiWriteData, withFtdi)

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

fdtiChunkSize :: Int
fdtiChunkSize = 63
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

mkBytesJtag ::  [Word8] -> [Word8] ->
                [Word8] -> [Word8] ->
                Maybe (Bool, [Bool]) ->
                [Word8]
mkBytesJtag v0 v1 vm0 vm1 msbBits =
  case msbBits of
    Nothing -> []
    Just (msb, bits) ->
      join (fmap (\v -> if v then v1 else v0) bits) ++ if msb then vm1 else vm0

mkJtagWrite:: [Bool] -> [Word8]
mkJtagWrite bits = mkBytesJtag jtagM0D0 jtagM0D1 jtagM1D0 jtagM1D1
                     $ revSplitMsb bits

mkJtagWriteRead:: [Bool] -> [Word8]
mkJtagWriteRead bits = mkBytesJtag jtagM0D0R jtagM0D1R jtagM1D0R jtagM1D1R
                         $ revSplitMsb bits

lsbToBool :: [Word8] -> [Bool]
lsbToBool b = fmap (\v -> v .&. 1 /= 0) b

-- @todo add Reader
data UsbBlasterState = UsbBlasterState
  { _usblD           :: DeviceHandle
  , _usblOut         :: [Word8]
  , _usblInReq       :: Int -- size and callback? array?
  , _usblRetries     :: Int
  , _usblTimeout     :: Int
  , _usblVirAddrBase :: Word16
  , _usblIrAddrLen   :: Int
  , _usblVirAddrLen  :: Int
  }
makeLenses ''UsbBlasterState

-- @todo better I/F - store all flushed input in state
flush :: (StateT UsbBlasterState) IO (Maybe [Bool])
flush = do
  s <- get
  _ <- liftIO $ ftdiWriteData (s^.usblD) (B.pack $ s^.usblOut)
  i <- liftIO $ if s^.usblInReq > 0
        then
          ftdiReadWithTimeout (s^.usblD) "" (s^.usblInReq)
                                 (s^.usblRetries) (s^.usblTimeout)
        else
          pure $ Just ""
  usblOut .= []
  usblInReq .= 0
  return $ lsbToBool . B.unpack <$> i

addOutput :: [Word8] -> (StateT UsbBlasterState) IO (Maybe [Bool])
addOutput o = do
  s <- get
  if length (s^.usblOut) + length o >= fdtiChunkSize
    then do
      f <- flush
      usblOut .= o
      return f
    else do
      usblOut <>= o
      return Nothing -- @todo need either for errors

readInput :: Int -> (StateT UsbBlasterState) IO (Maybe [Bool])
readInput sz = do
  s <- get
  if s^.usblInReq + sz >= fdtiChunkSize
    then do
      f <- flush
      usblInReq .= sz
      return f
    else do
      usblInReq += sz
      return Nothing

withUSBBlaster :: Word16 -> Int -> Int
                ->(StateT UsbBlasterState) IO (Maybe B.ByteString)
                -> IO (Maybe [Char])
withUSBBlaster ad irl virl f = do
    dh <- ftdiInit
    case dh of
      Left err -> return $ Just $ "Error:" ++ show err
      Right _ ->
        withFtdi ( \d -> do
          ftdiUSBOpen d (0x09fb, 0x6001)
          ftdiUSBReset d
          _ <- tapReset d
          _ <- runStateT f (UsbBlasterState d [] 0 5 1000 ad irl virl)
          ftdiUSBClose d
          ftdiDeInit d
          return Nothing )

-- @todo cleanup - monad loop
ftdiReadWithTimeout :: DeviceHandle -> B.ByteString -> Int -> Int -> Int ->
                      IO (Maybe B.ByteString)
ftdiReadWithTimeout d acc left iter delay =
   if iter == 0
      then do
        pure Nothing
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

-- @todo ignored returns, errors
irWrite:: [Bool] -> (StateT UsbBlasterState) IO (Maybe B.ByteString)
irWrite b = do
  _ <- addOutput tapShiftVIRSeq
  _ <- addOutput $ mkJtagWrite b
  _ <- addOutput tapEndSeq
  pure $ Just "@TODO fix me"

virWrite:: Word8 -> (StateT UsbBlasterState) IO (Maybe B.ByteString)
virWrite addr = do
  -- @todo addr checks?
  s <- get
  _ <- irWrite $ toBits (s^.usblIrAddrLen) irAddrVir
  _ <- addOutput tapShiftVDRSeq -- @todo name!?
  _ <- addOutput $ mkJtagWrite $ toBits (s^.usblVirAddrLen) $ (s^.usblVirAddrBase) + fromIntegral addr
  _ <- addOutput tapEndSeq
  pure $ Just "@TODO fix me"

vdrWrite:: [Bool] -> (StateT UsbBlasterState) IO (Maybe B.ByteString)
vdrWrite b = do
  s <- get
  _ <- irWrite $ toBits (s^.usblIrAddrLen) irAddrVdr
  _ <- addOutput tapShiftVDRSeq
  _ <- addOutput $ mkJtagWrite b
  _ <- addOutput tapEndSeq
  pure $ Just "@TODO fix me"

vdrWriteRead:: [Bool] -> (StateT UsbBlasterState) IO (Maybe B.ByteString)
vdrWriteRead b = do
  s <- get
  _ <- irWrite $ toBits (s^.usblIrAddrLen) irAddrVdr
  _ <- addOutput tapShiftVDRSeq
  _ <- addOutput $ mkJtagWriteRead b
  _ <- readInput $ length b
  _ <- addOutput tapEndSeq
  pure $ Just "@TODO fix me"

printState :: UsbBlasterState -> IO()
printState s = putStrLn $ show (s^.usblOut) ++ ", " ++ show (s^.usblInReq) ++ ", " ++ show (s^.usblInReq)

virAddrWrite, virAddrRead, virAddrOff :: Word8
virAddrWrite = 0x02
virAddrRead  = 0x01
virAddrOff   = 0x00
