-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_topentity_0 is
  port(i               : in packetprocessordf_types.tup2;
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       result          : out packetprocessordf_types.counterstate);
end;

architecture structural of packetprocessordf_topentity_0 is
  signal app_arg   : std_logic_vector(11 downto 0);
  signal app_arg_0 : boolean;
  signal x         : std_logic_vector(11 downto 0);
  signal y         : boolean;
begin
  app_arg <= x;
  
  app_arg_0 <= y;
  
  x <= i.tup2_sel0;
  
  y <= i.tup2_sel1;
  
  packetprocessordf_packetprocessor_result : entity packetprocessordf_packetprocessor
    port map
      (result          => result
      ,system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,memop           => app_arg
      ,en              => app_arg_0);
end;
