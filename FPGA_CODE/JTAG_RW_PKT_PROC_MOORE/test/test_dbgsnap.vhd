library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.dbgsnap;

entity dbgsnap_testbench is
  port(done : out boolean);
end;

architecture structural of dbgsnap_testbench is
  signal finished        : boolean;
  signal clk : boolean;
  signal tr : std_logic;
  signal dbg_in : unsigned(15 downto 0):= to_unsigned(0,16);  
  	function to_stdulogic( V: Boolean ) return std_ulogic is 
	begin 
		 if V then 
			  return '1'; 
		 else 
			  return '0'; 
		 end if;
	end to_stdulogic;
begin
  done <= finished;
  
  -- pragma translate_off
  process is
  begin
    clk <= false;
    wait for 3 ns;
    while (not finished) loop
      clk <= not clk;
      wait for 500 ns;
      clk <= not clk;
      wait for 500 ns;
    end loop;
    wait;
  end process;
  
    process is
  begin
    wait for 3 ns;
    while (not finished) loop
      dbg_in <= dbg_in + 1;
      wait for 1000 ns;
    end loop;
    wait;
  end process;
  
  -- pragma translate_on
  
  -- pragma translate_off
  -- pragma translate_on
  
  totest : entity dbgsnap
    port map
      ( clk => to_stdulogic(clk)
	   , tr  => tr
      , dbg_in => std_logic_vector(dbg_in)
      );
	
  tr <=
  -- pragma translate_off
              '0',
  -- pragma translate_on
              '1'
  -- pragma translate_off
              after 1000 ns
  -- pragma translate_on
              ;
  
  finished <=
  -- pragma translate_off
              false,
  -- pragma translate_on
              true
  -- pragma translate_off
              after  8200000 ns
  -- pragma translate_on
              ;
end;
