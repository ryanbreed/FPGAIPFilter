-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_moore is
  port(w3              : in std_logic_vector(28 downto 0);
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       s1              : out packetprocessordf_types.counterstate);
end;

architecture structural of packetprocessordf_moore is
  signal s1_app_arg : packetprocessordf_types.counterstate;
  signal s1_rec     : packetprocessordf_types.counterstate;
begin
  packetprocessordf_cnt_s1_app_arg : entity packetprocessordf_cnt
    port map
      (result => s1_app_arg
      ,s      => s1_rec
      ,x      => w3);
  
  -- register begin
  packetprocessordf_moore_register : process(system1000,system1000_rstn)
  begin
    if system1000_rstn = '0' then
      s1_rec <= (counterstate_sel0 => to_unsigned(0,11),counterstate_sel1 => to_unsigned(2047,11),counterstate_sel2 => to_unsigned(0,4),counterstate_sel3 => to_unsigned(0,16),counterstate_sel4 => std_logic_vector'("0" & "00000000"),counterstate_sel5 => false,counterstate_sel6 => packetprocessordf_types.array_of_tup3'((tup3_sel0 => to_unsigned(2047,11),tup3_sel1 => to_unsigned(0,8),tup3_sel2 => to_unsigned(0,8)),(tup3_sel0 => to_unsigned(2047,11),tup3_sel1 => to_unsigned(0,8),tup3_sel2 => to_unsigned(0,8)),(tup3_sel0 => to_unsigned(2047,11),tup3_sel1 => to_unsigned(0,8),tup3_sel2 => to_unsigned(0,8)),(tup3_sel0 => to_unsigned(2047,11),tup3_sel1 => to_unsigned(0,8),tup3_sel2 => to_unsigned(0,8))),counterstate_sel7 => to_unsigned(0,2),counterstate_sel8 => false);
    elsif rising_edge(system1000) then
      s1_rec <= s1_app_arg;
    end if;
  end process;
  -- register end
  
  s1 <= s1_rec;
end;
