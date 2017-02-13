{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE DeriveLift          #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE GADTs               #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeOperators       #-}

module PacketProcessorDF (packetProcessor, MemOp(..), DataV, MemAddr, topEntity) where

import           CLaSH.Prelude

import           Control.DeepSeq
import           GHC.Generics    (Generic)


type DataV = Unsigned 8
type MemAddr = Unsigned 11

data MemOp = READ MemAddr | WRITE DataV
  deriving (Lift, Show, ShowX, Generic, NFData); -- For clash interactive

data Counter = Increment DataV | Reset | Off;

data CounterState = CounterState
  { counter   :: MemAddr
  , left      :: MemAddr
  , ihl       :: Unsigned 4
  , pktLength :: Unsigned 16
  , lastData  :: Maybe DataV
  , done      :: Bool
  } deriving (Show, ShowX, Generic, NFData, Eq)

resetCounterState :: CounterState
resetCounterState = CounterState 0 2047 0 0 Nothing False

cnt :: CounterState     -- Current state
    -> Counter          -- Input
    -> CounterState     -- Updated state
cnt s x = case x of
  Increment d -> let nihl
                      | counter s == 0 = unpack (slice d3 d0 d)
                      | otherwise = ihl s
                     npl
                      | counter s == 2 = setSlice d15 d8 (pack d) $ pktLength s
                      | counter s == 3 = setSlice d7 d0 (pack d) $ pktLength s
                      | otherwise = pktLength s
                     nleft
                      | counter s == 4 = unpack (slice d10 d0 (pktLength s - 5))
                      | otherwise = left s - 1
                     nd = if left s /= 0
                            then Just d
                            else Nothing
                     ndone = left s == 0 in
    s { counter = counter s + 1, left = nleft, ihl = nihl, pktLength = npl, lastData = nd, done = ndone}
  Reset -> resetCounterState
  Off -> s {done = left s == 0}

packetProcessor::
    Signal MemOp -> Signal Bool -- ^ Memory operation
    -> Signal CounterState  --
packetProcessor memOp en = counterOp
  where
    counterOp = moore cnt id resetCounterState (getCounterOp <$> memOp <*> en)

    getCounterOp::MemOp -> Bool -> Counter
    getCounterOp m e = case (e, m) of
      (True, WRITE x) -> Increment x
      (_, _) -> Off

topEntity::Signal (MemOp, Bool) -- ^ Memory operation
  -> Signal CounterState
topEntity i = let (m, b) = unbundle i in
   packetProcessor m b

testInput :: Signal (MemOp, Bool)
testInput = stimuliGenerator
  (  (WRITE 0x45, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x70, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x40, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x40, True)
  :> (WRITE 0x11, True)
  :> (WRITE 0x24, True)
  :> (WRITE 0x3b, True)
  :> (WRITE 0x0a, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0x0a, True)
  :> (WRITE 0x0a, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0x37, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x35, True)
  :> (WRITE 0x3e, True)
  :> (WRITE 0x1a, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x5c, True)
  :> (WRITE 0x65, True)
  :> (WRITE 0xaa, True)
  :> (WRITE 0x07, True)
  :> (WRITE 0xec, True)
  :> (WRITE 0x81, True)
  :> (WRITE 0x80, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x02, True)
  :> (WRITE 0x32, True)
  :> (WRITE 0x35, True)
  :> (WRITE 0x03, True)
  :> (WRITE 0x31, True)
  :> (WRITE 0x35, True)
  :> (WRITE 0x36, True)
  :> (WRITE 0x03, True)
  :> (WRITE 0x31, True)
  :> (WRITE 0x37, True)
  :> (WRITE 0x36, True)
  :> (WRITE 0x03, True)
  :> (WRITE 0x32, True)
  :> (WRITE 0x31, True)
  :> (WRITE 0x30, True)
  :> (WRITE 0x07, True)
  :> (WRITE 0x69, True)
  :> (WRITE 0x6e, True)
  :> (WRITE 0x2d, True)
  :> (WRITE 0x61, True)
  :> (WRITE 0x64, True)
  :> (WRITE 0x64, True)
  :> (WRITE 0x72, True)
  :> (WRITE 0x04, True)
  :> (WRITE 0x61, True)
  :> (WRITE 0x72, True)
  :> (WRITE 0x70, True)
  :> (WRITE 0x61, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x0c, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0xc0, True)
  :> (WRITE 0x0c, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x0c, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x01, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x89, True)
  :> (WRITE 0x40, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x1b, True)
  :> (WRITE 0x07, True)
  :> (WRITE 0x75, True)
  :> (WRITE 0x6e, True)
  :> (WRITE 0x6b, True)
  :> (WRITE 0x6e, True)
  :> (WRITE 0x6f, True)
  :> (WRITE 0x77, True)
  :> (WRITE 0x6e, True)
  :> (WRITE 0x0d, True)
  :> (WRITE 0x74, True)
  :> (WRITE 0x65, True)
  :> (WRITE 0x6c, True)
  :> (WRITE 0x73, True)
  :> (WRITE 0x74, True)
  :> (WRITE 0x72, True)
  :> (WRITE 0x61, True)
  :> (WRITE 0x67, True)
  :> (WRITE 0x6c, True)
  :> (WRITE 0x6f, True)
  :> (WRITE 0x62, True)
  :> (WRITE 0x61, True)
  :> (WRITE 0x6c, True)
  :> (WRITE 0x03, True)
  :> (WRITE 0x6e, True)
  :> (WRITE 0x65, True)
  :> (WRITE 0x74, True)
  :> (WRITE 0x00, True)
  :> (WRITE 0x00, False)
  :> Nil )

expectedOutput :: Signal CounterState -> Signal Bool
expectedOutput = outputVerifier
  (  CounterState 0 2047 0 0 Nothing False
  :> Nil)
