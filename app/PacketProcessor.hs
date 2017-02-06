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
    Signal MemOp -- ^ Memory operation
    -> ( Signal DataV,  -- ^ Data from read port
         Signal Bool, -- ^ Done
         Signal Bool  -- ^ Error
       )
packetProcessor memOp =
    (ramOut, done, err)
  where
    ramOut = blockRamPow2 (replicate (SNat :: SNat 2048) (0::DataV)) rAddr wrOp

    (rAddr, wrEn, wrOp) = unbundle $ getOp <$> memOp <*> wrAddr
    getOp::MemOp -> MemAddr -> (MemAddr, Bool, Maybe (MemAddr, DataV))
    getOp m wr = case m of
      READ a -> (a, False, Nothing)
      WRITE x -> (0, True, Just (wr, x))

    -- @todo reset for reuse
    wrAddr = register 0 $ mux wrEn (clampedInc <$> wrAddr) wrAddr

    -- @todo packet count, valid fields etc
    done = wrAddr .==. 2047
    err = wrAddr .==. 2047

    clampedInc val
        | val == 2047 = 2047
        | otherwise   = val + 1

topEntity::Signal MemOp -- ^ Memory operation
  -> Signal ( DataV, -- ^ Read data
       Bool, -- ^ Done
       Bool  -- ^ Error
     )
topEntity i = bundle (packetProcessor i)

-- testInput :: Signal MemOp
-- testInput = stimuliGenerator $(listToVecTH
--   [ WRITE 101
--   , WRITE 102
--   , WRITE 103
--   , WRITE 104
--   , READ 0
--   , READ 1
--   , READ 2
--   , READ 3
--   ])
--
-- expectedOutput :: Signal (DataV, Bool, Bool) -> Signal Bool
-- expectedOutput = outputVerifier $(listToVecTH
--   [ (0, False, False)
--   , (101, False, False)
--   , (101, False, False)
--   , (101, False, False)
--   , (101, False, False)
--   , (102, False, False)
--   , (103, False, False)
--   , (104, False, False)
--   ])
