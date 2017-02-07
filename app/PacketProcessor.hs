{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DeriveLift #-}

module PacketProcessor (packetProcessor, MemOp(..), DataV, MemAddr, topEntity) where

import CLaSH.Prelude

type DataV = Unsigned 8
type MemAddr = Unsigned 11

data MemOp = READ MemAddr | WRITE DataV deriving Lift;

packetProcessor::
    Signal MemOp -> Signal Bool -- ^ Memory operation
    -> ( Signal (Maybe DataV),  -- ^ Data from read port
         Signal Bool, -- ^ Done
         Signal Bool  -- ^ Error
       )
packetProcessor memOp en = (ramOut, done, err)
  where
    ramOut :: Signal (Maybe DataV)
    ramOut = enableJust
            <$> readNew (blockRamPow2 (replicate (SNat :: SNat 2048) (0::DataV))) rAddr wrOp
            <*> memEn

    (rAddr, wrEn, memEn, wrOp) = unbundle $ getOp <$> memOp <*> en <*> wrAddr

    getOp::MemOp -> Bool -> MemAddr -> (MemAddr, Bool, Bool, Maybe (MemAddr, DataV))
    getOp m en wr = case (en, m) of
      (_, READ a) -> (a, False, True, Nothing)
      (True, WRITE x) -> (0::MemAddr, True, True, Just (wr, x))
      (False, _) -> (0, False, False, Nothing)

    -- @todo reset for reuse
    wrAddr :: Signal MemAddr
    wrAddr = register (0::MemAddr) $ mux wrEn (clampedInc <$> wrAddr) wrAddr

    -- @todo packet count, valid fields etc
    done::Signal Bool
    done = wrAddr .==. 2047
    err::Signal Bool
    err = wrAddr .==. 2047

    enableJust::DataV -> Bool -> Maybe DataV
    enableJust v b = if b then Just v else Nothing

    clampedInc::MemAddr -> MemAddr
    clampedInc val
        | val == 2047 = 2047
        | otherwise   = val + 1

topEntity::Signal (MemOp, Bool) -- ^ Memory operation
  -> Signal ( Maybe DataV, -- ^ Read data
       Bool, -- ^ Done
       Bool  -- ^ Error
     )
topEntity i = let (m, b) = unbundle i in
  bundle (packetProcessor m b)

testInput :: Signal (MemOp, Bool)
testInput = stimuliGenerator
  (  (WRITE 100, True)
  :> (WRITE 101, True)
  :> (WRITE 102, True)
  :> (WRITE 103, True)
  :> (READ 0, True)
  :> (READ 1, True)
  :> (READ 2, True)
  :> (READ 3, True)
  :> Nil )

expectedOutput :: Signal (DataV, Bool, Bool) -> Signal Bool
expectedOutput = outputVerifier
  (  (0, False, False)
  :> (100, False, False)
  :> (100, False, False)
  :> (100, False, False)
  :> (100, False, False)
  :> (100, False, False)
  :> (101, False, False)
  :> (102, False, False)
  :> (103, False, False)
  :> Nil)
