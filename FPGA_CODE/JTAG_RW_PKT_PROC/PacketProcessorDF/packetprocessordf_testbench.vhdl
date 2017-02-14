-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_testbench is
  port(done : out boolean);
end;

architecture structural of packetprocessordf_testbench is
  signal finished        : boolean;
  signal system1000      : std_logic;
  signal system1000_rstn : std_logic;
  signal i               : packetprocessordf_types.tup2;
  signal result          : packetprocessordf_types.counterstate;
begin
  done <= finished;
  
  -- pragma translate_off
  process is
  begin
    system1000 <= '0';
    wait for 3 ns;
    while (not finished) loop
      system1000 <= not system1000;
      wait for 500 ns;
      system1000 <= not system1000;
      wait for 500 ns;
    end loop;
    wait;
  end process;
  -- pragma translate_on
  
  -- pragma translate_off
  system1000_rstn <= '0',
             '1' after 2 ns;
  -- pragma translate_on
  
  totest : entity packetprocessordf_topentity_0
    port map
      (system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,i               => i
      ,result          => result);
  
  i <= packetprocessordf_types.tup2'(std_logic_vector'(0 to 28 => 'X'),true);
  
  finished <=
  -- pragma translate_off
              false,
  -- pragma translate_on
              true
  -- pragma translate_off
              after 100 ns
  -- pragma translate_on
              ;
end;
