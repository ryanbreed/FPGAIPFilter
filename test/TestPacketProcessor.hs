{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}

import Protolude
import CLaSH.Prelude hiding (drop, print)
import PacketProcessor

testInput :: Signal MemOp
testInput = stimuliGenerator $(listToVecTH
  [ WRITE 100
  , READ 0
  , WRITE 101
  , WRITE 102
  , WRITE 103
  , READ 3
  , READ 2
  , READ 1
  ])

main :: IO ()
main = printX $ sampleN 9 $ topEntity testInput
