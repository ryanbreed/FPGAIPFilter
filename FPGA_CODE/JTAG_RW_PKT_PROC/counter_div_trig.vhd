library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity counter_div_trig is
   generic 
		( OFFSET    : integer
	   ; BIT_WIDTH : integer
	   );
   port
		( clk         : in  std_logic
		; tr          : in  std_logic
		; counter_out : out std_logic_vector((BIT_WIDTH - 1) downto 0)
      );
end entity counter_div_trig;

architecture syn of counter_div_trig is
   constant TOP_BIT    : integer := OFFSET + BIT_WIDTH - 1;
	
   signal counter_data : std_logic_vector(31 downto 0) := (others => '0');  
  
begin

   process(clk, counter_data, tr)
   begin
      if rising_edge(clk) then
			if (((or_reduce(counter_data(TOP_BIT downto OFFSET)) = '1') or (tr = '1')) 
				   and (and_reduce(counter_data(TOP_BIT downto OFFSET)) = '0'))  
			then
				counter_data <= std_logic_vector(unsigned(counter_data) + 1);
			end if;
      end if; 
   end process;
  
   counter_out <= counter_data(TOP_BIT downto OFFSET);

end architecture syn;
