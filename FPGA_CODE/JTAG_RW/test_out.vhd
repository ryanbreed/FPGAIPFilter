library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_out is
   port(  
         clk         : in  std_logic;
         counter_out : out std_logic_vector(6 downto 0)
       );
end entity test_out;

architecture syn of test_out is
   
   signal counter_data : std_logic_vector(31 downto 0) := (others => '0');  
  
begin

   process(clk)
   begin
    
      if rising_edge(clk) then
         counter_data <= std_logic_vector(unsigned(counter_data) + 1);
      end if; 
    
   end process;
  
   counter_out <= counter_data(6 downto 0);

end architecture syn;
