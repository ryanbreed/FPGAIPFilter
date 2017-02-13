-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_topentity is
  port(input_0_0       : in std_logic_vector(11 downto 0);
       input_0_1       : in boolean;
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       output_0_0      : out unsigned(10 downto 0);
       output_0_1      : out unsigned(10 downto 0);
       output_0_2      : out unsigned(3 downto 0);
       output_0_3      : out unsigned(15 downto 0));
end;

architecture structural of packetprocessordf_topentity is
  signal input_0  : packetprocessordf_types.tup2;
  signal output_0 : packetprocessordf_types.counterstate;
begin
  input_0 <= (tup2_sel0 => input_0_0
             ,tup2_sel1 => input_0_1);
  
  packetprocessordf_topentity_0_inst : entity packetprocessordf_topentity_0
    port map
      (i               => input_0
      ,system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,result          => output_0);
  
  output_0_0 <= output_0.counterstate_sel0;
  
  output_0_1 <= output_0.counterstate_sel1;
  
  output_0_2 <= output_0.counterstate_sel2;
  
  output_0_3 <= output_0.counterstate_sel3;
end;
