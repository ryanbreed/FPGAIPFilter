{-|
Module      : JtagRW
Description : JtagRW's main module

 Reading and writing to Altera virtual JTAG for cyclone on DE0-Nano board.
 Requires that the virtual IR be two bits wide and decoded as per example in
 DE0_Nano_JTAG_RW.
-}
module JtagRW
    (
      tapReset,
      virAddrWrite, virAddrRead, virAddrOff,
      virWrite, vdrWrite, vdrWriteRead, toBits, fromBits
    ) where

import Lib.Prelude
import Lib.JtagRW
