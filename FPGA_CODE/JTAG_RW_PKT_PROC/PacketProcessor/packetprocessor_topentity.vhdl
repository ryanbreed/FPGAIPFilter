-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessor_types.all;

entity packetprocessor_topentity is
  port(input_0_0       : in std_logic_vector(11 downto 0);
       input_0_1       : in boolean;
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       output_0_0      : out std_logic_vector(8 downto 0);
       output_0_1      : out boolean;
       output_0_2      : out boolean);
end;

architecture structural of packetprocessor_topentity is
  signal input_0  : packetprocessor_types.tup2;
  signal output_0 : packetprocessor_types.tup3;
begin
  input_0 <= (tup2_sel0 => input_0_0
             ,tup2_sel1 => input_0_1);
  
  packetprocessor_topentity_0_inst : entity packetprocessor_topentity_0
    port map
      (i               => input_0
      ,system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,case_alt        => output_0);
  
  output_0_0 <= output_0.tup3_sel0;
  
  output_0_1 <= output_0.tup3_sel1;
  
  output_0_2 <= output_0.tup3_sel2;
end;
