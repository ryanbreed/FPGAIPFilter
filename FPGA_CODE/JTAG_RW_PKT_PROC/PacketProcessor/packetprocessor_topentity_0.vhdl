-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessor_types.all;

entity packetprocessor_topentity_0 is
  port(i               : in std_logic_vector(11 downto 0);
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       case_alt        : out packetprocessor_types.tup3);
end;

architecture structural of packetprocessor_topentity_0 is
  signal case_scrut : packetprocessor_types.tup3;
  signal ww1        : unsigned(7 downto 0);
  signal ww2        : boolean;
  signal ww3        : boolean;
begin
  packetprocessor_packetprocessor_case_scrut : entity packetprocessor_packetprocessor
    port map
      (result          => case_scrut
      ,system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,memop           => i);
  
  case_alt <= (tup3_sel0 => ww1
              ,tup3_sel1 => ww2
              ,tup3_sel2 => ww3);
  
  ww1 <= case_scrut.tup3_sel0;
  
  ww2 <= case_scrut.tup3_sel1;
  
  ww3 <= case_scrut.tup3_sel2;
end;
