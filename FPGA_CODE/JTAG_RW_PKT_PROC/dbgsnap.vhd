library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.counter_div_trig;
use work.dbgram;

entity dbgsnap is
   port
		( clk        : in std_logic
	   ; tr         : in std_logic
      ;dbg_in      : in std_logic_vector(15 downto 0)
      );
end entity dbgsnap;

architecture syn of dbgsnap is
	component dbgram IS
		port
			( address	: in  std_logic_vector (12 DOWNTO 0)
			; clock		: in  std_logic  := '1'
			; data		: in  std_logic_vector (15 DOWNTO 0)
			; wren		: in  std_logic 
			; q		   : OUT std_logic_vector (15 DOWNTO 0)
			);
	end component dbgram;
	
	component counter_div_trig is
		generic 
			( OFFSET    : integer
			; BIT_WIDTH : integer
			);
		port
			( clk         : in  std_logic
			; tr          : in  std_logic
			; counter_out : out std_logic_vector((BIT_WIDTH - 1) downto 0)
			);
	end component counter_div_trig;

   signal dbg_addr : std_logic_vector(12 downto 0) := (others => '0');  
  
begin
	
	inst_dbg_addr : counter_div_trig 
      generic map 
			( OFFSET => 0
			, BIT_WIDTH => 13
			)
      port map 
			( clk         => clk
			, tr => tr
			, counter_out => dbg_addr
         );
					
	 inst_dbgram : dbgram 
		port map
			( address	=> dbg_addr
			, clock		=> clk
			, data		=> dbg_in
			, wren		=> '1'
			-- , q		=>
			);
		
end architecture syn;
