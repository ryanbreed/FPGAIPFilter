-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_packetprocessor is
  port(memop           : in std_logic_vector(11 downto 0);
       en              : in boolean;
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       result          : out packetprocessordf_types.counterstate);
end;

architecture structural of packetprocessordf_packetprocessor is
  signal app_arg    : std_logic_vector(9 downto 0);
  signal case_alt   : std_logic_vector(9 downto 0);
  signal case_alt_0 : std_logic_vector(9 downto 0);
  signal x          : unsigned(7 downto 0);
begin
  app_arg <= case_alt when en else
             std_logic_vector'("10" & "00000000");
  
  with (memop(11 downto 11)) select
    case_alt <= std_logic_vector'("10" & "00000000") when "0",
                case_alt_0 when others;
  
  case_alt_0 <= std_logic_vector'("00" & std_logic_vector(x));
  
  x <= unsigned(memop(10 downto 3));
  
  packetprocessordf_moore_result : entity packetprocessordf_moore
    port map
      (s1              => result
      ,system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,w3              => app_arg);
end;
