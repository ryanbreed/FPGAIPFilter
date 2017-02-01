library ieee;
use ieee.std_logic_1164.all;

entity jtagif2 is
	generic ( DR_BITS : INTEGER := 6 ) ;
   port( tck         : in  std_logic;
			tdi         : in  std_logic;
			tdo         : out std_logic;
			aclr        : in  std_logic;
			sdr         : in  std_logic;
			udr         : in  std_logic;
			cdr         : in  std_logic;
			ir_in       : in  std_logic_vector(1 downto 0);
         ir_in_dec   : out std_logic_vector(DR_BITS downto 0);
			ir_out_v    : in  std_logic_vector(DR_BITS downto 0);
			ir_out_set  : in  std_logic;
			ir_out_done : out std_logic;
			ir_out      : out std_logic_vector(1 downto 0)
       );
end entity jtagif2;


architecture rtl of jtagif2 is

	constant READV			: std_logic_vector(1 downto 0) := "01";
	constant WRITEV		: std_logic_vector(1 downto 0) := "10";

	signal read_in			: std_logic_vector(DR_BITS downto 0);
	signal write_out		: std_logic_vector(DR_BITS downto 0);
	
	
begin
	process(tck)
	begin
		if rising_edge(tck) then
			if ir_in = WRITEV then
				if sdr = '1' then
					read_in <= tdi & read_in(DR_BITS downto 1);
				elsif udr = '1' then
					ir_in_dec <= read_in;
				end if;
			elsif ir_in = READV then
				if cdr = '1' then
					write_out <= ir_out_v;
				elsif sdr = '1' then
					write_out <= tdi & write_out(DR_BITS downto 1);
				end if;
			end if;
		end if;
	end process;
	
	with ir_in select
		tdo <= write_out(0) when READV, read_in(0) when WRITEV, tdi when others;
		
end architecture;
	 
	
	
	
			
			

	


