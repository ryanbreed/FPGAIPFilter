library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_hold is
   generic 
		( HOLD_FOR : integer
		);
   port
		( clk      : in  std_logic
		; hold_out : out std_logic
      );
end entity counter_hold;

architecture syn of counter_hold is
   
   signal counter_data : std_logic_vector(31 downto 0) := (others => '0');  
  
begin

   process(clk)
   begin
    
      if rising_edge(clk) then
			if (unsigned(counter_data) < HOLD_FOR) then
				counter_data <= std_logic_vector(unsigned(counter_data) + 1);
				hold_out <= '0';
			else
				hold_out <= '1';
			end if;
      end if; 
    
   end process;
  

end architecture syn;
