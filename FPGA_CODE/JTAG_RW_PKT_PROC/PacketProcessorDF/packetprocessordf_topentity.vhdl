-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_topentity is
  port(input_0_0       : in std_logic_vector(28 downto 0);
       input_0_1       : in boolean;
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       output_0_0      : out unsigned(10 downto 0);
       output_0_1      : out unsigned(10 downto 0);
       output_0_2      : out unsigned(3 downto 0);
       output_0_3      : out unsigned(15 downto 0);
       output_0_4      : out std_logic_vector(8 downto 0);
       output_0_5      : out boolean;
       output_0_6_0_0  : out unsigned(10 downto 0);
       output_0_6_0_1  : out unsigned(7 downto 0);
       output_0_6_0_2  : out unsigned(7 downto 0);
       output_0_6_1_0  : out unsigned(10 downto 0);
       output_0_6_1_1  : out unsigned(7 downto 0);
       output_0_6_1_2  : out unsigned(7 downto 0);
       output_0_6_2_0  : out unsigned(10 downto 0);
       output_0_6_2_1  : out unsigned(7 downto 0);
       output_0_6_2_2  : out unsigned(7 downto 0);
       output_0_6_3_0  : out unsigned(10 downto 0);
       output_0_6_3_1  : out unsigned(7 downto 0);
       output_0_6_3_2  : out unsigned(7 downto 0);
       output_0_7      : out unsigned(1 downto 0);
       output_0_8      : out boolean);
end;

architecture structural of packetprocessordf_topentity is
  signal input_0      : packetprocessordf_types.tup2;
  signal output_0     : packetprocessordf_types.counterstate;
  signal output_0_6   : packetprocessordf_types.array_of_tup3(0 to 3);
  signal output_0_6_0 : packetprocessordf_types.tup3;
  signal output_0_6_1 : packetprocessordf_types.tup3;
  signal output_0_6_2 : packetprocessordf_types.tup3;
  signal output_0_6_3 : packetprocessordf_types.tup3;
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
  
  output_0_4 <= output_0.counterstate_sel4;
  
  output_0_5 <= output_0.counterstate_sel5;
  
  output_0_6 <= output_0.counterstate_sel6;
  
  output_0_7 <= output_0.counterstate_sel7;
  
  output_0_8 <= output_0.counterstate_sel8;
  
  output_0_6_0 <= output_0_6(0);
  
  output_0_6_1 <= output_0_6(1);
  
  output_0_6_2 <= output_0_6(2);
  
  output_0_6_3 <= output_0_6(3);
  
  output_0_6_0_0 <= output_0_6_0.tup3_sel0;
  
  output_0_6_0_1 <= output_0_6_0.tup3_sel1;
  
  output_0_6_0_2 <= output_0_6_0.tup3_sel2;
  
  output_0_6_1_0 <= output_0_6_1.tup3_sel0;
  
  output_0_6_1_1 <= output_0_6_1.tup3_sel1;
  
  output_0_6_1_2 <= output_0_6_1.tup3_sel2;
  
  output_0_6_2_0 <= output_0_6_2.tup3_sel0;
  
  output_0_6_2_1 <= output_0_6_2.tup3_sel1;
  
  output_0_6_2_2 <= output_0_6_2.tup3_sel2;
  
  output_0_6_3_0 <= output_0_6_3.tup3_sel0;
  
  output_0_6_3_1 <= output_0_6_3.tup3_sel1;
  
  output_0_6_3_2 <= output_0_6_3.tup3_sel2;
end;
