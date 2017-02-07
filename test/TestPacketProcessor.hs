{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}

import Protolude
import CLaSH.Prelude hiding (drop, print)
import PacketProcessor

testInput :: Signal (MemOp, Bool)
testInput = stimuliGenerator $(listToVecTH
  [ (WRITE 100, True)
  , (WRITE 101, True)
  , (WRITE 102, True)
  , (WRITE 103, True)
  , (WRITE 104, False)
  , (READ 0, True)
  , (READ 1, True)
  , (READ 2, True)
  , (READ 3, True)
  ])

main :: IO ()
main = printX $ sampleN 9 $ topEntity testInput
