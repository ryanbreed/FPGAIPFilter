library ieee;
use ieee.std_logic_1164.all;

entity jtagif2 is
   generic 
		( DR_BITS : integer  
		);
   port
		( tck         : in  std_logic
		; tdi         : in  std_logic
		; tdo         : out std_logic
		; aclr        : in  std_logic
		; sdr         : in  std_logic
		; udr         : in  std_logic
		; cdr         : in  std_logic
		; ir_in       : in  std_logic_vector(2 downto 0)
		; vdr_out     : out std_logic_vector(DR_BITS - 1 downto 0)
		; vdr_out_rdy : out std_logic
		; vdr_in      : in  std_logic_vector(DR_BITS - 1 downto 0)
		; vdr_in_rdy  : out std_logic
		; ir_out      : out std_logic_vector(2 downto 0)
      );
end entity jtagif2;


architecture rtl of jtagif2 is
   constant TOP_BIT     : integer := DR_BITS - 1;
   
   constant READV       : std_logic_vector(2 downto 0) := "001";
   constant WRITEV      : std_logic_vector(2 downto 0) := "010";

   signal read_in       : std_logic_vector(TOP_BIT downto 0);
   signal write_out     : std_logic_vector(TOP_BIT downto 0);
   signal vdr_out_rdy_1 : std_logic;
   signal vdr_out_rdy_2 : std_logic;
   
begin
   process(tck)
   begin
      if rising_edge(tck) then
         if ir_in = WRITEV then
            if sdr = '1' then
               read_in <= tdi & read_in(TOP_BIT downto 1);
            elsif udr = '1' then
               vdr_out <= read_in;
            end if;
         elsif ir_in = READV then
            if cdr = '1' then
               write_out <= vdr_in;
            elsif sdr = '1' then
               write_out <= tdi & write_out(TOP_BIT downto 1);
            end if;
         end if;
      end if;
   end process;
   
   process(tck)
   begin
      if rising_edge(tck) then
         if ir_in = WRITEV and udr = '1' then
            vdr_out_rdy_2 <= '1';
         else 
            vdr_out_rdy_2 <= '0';
         end if;
      end if;
   end process;
   
   process(tck)
   begin
      if rising_edge(tck) then
         vdr_out_rdy_1 <= vdr_out_rdy_2;
         vdr_out_rdy   <= vdr_out_rdy_2 and not vdr_out_rdy_1;
      end if;
   end process;
   
   process(tck)
   begin
      if rising_edge(tck) then
         if ir_in = READV and cdr = '1' then
            vdr_in_rdy <= '1';
         else 
            vdr_in_rdy <= '0';
         end if;
      end if;
   end process;
   
   with ir_in select
      tdo <= write_out(0) when READV, read_in(0) when WRITEV, tdi when others;
      
end architecture;
    
   
   
   
         
         

   


