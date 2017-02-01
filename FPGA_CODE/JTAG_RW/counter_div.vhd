library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_div is
   generic ( OFFSET : INTEGER; BIT_WIDTH : INTEGER) ;
   port( clk         : in  std_logic;
         counter_out : out std_logic_vector((BIT_WIDTH - 1) downto 0)
       );
end entity counter_div;

architecture syn of counter_div is
   
   signal counter_data : std_logic_vector(31 downto 0) := (others => '0');  
  
begin

   process(clk)
   begin
    
      if rising_edge(clk) then
         counter_data <= std_logic_vector(unsigned(counter_data) + 1);
      end if; 
    
   end process;
  
   counter_out <= counter_data((OFFSET + BIT_WIDTH - 1) downto OFFSET);

end architecture syn;
