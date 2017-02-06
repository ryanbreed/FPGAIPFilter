{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}

import Protolude
import CLaSH.Prelude hiding (drop, print)
import PacketProcessor

topEntity ::   Signal MemOp -- ^ Memory operation
  -> Signal ( DataV, -- ^ Read data
       Bool, -- ^ Done
       Bool  -- ^ Error
     )
topEntity i = bundle (packetProcessor i)

testInput :: Signal MemOp
testInput = stimuliGenerator $(listToVecTH
  [ WRITE 101
  , WRITE 102
  , WRITE 103
  , WRITE 104
  , READ 0
  , READ 1
  , READ 2
  , READ 3
  ])

main :: IO ()
main = print $ drop 1 (sampleN 9 (topEntity testInput))
