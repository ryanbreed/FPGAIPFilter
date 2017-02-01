library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de0_nano_system is
  port ( CLOCK_50      : in  std_logic;
			
			GPIO_0       : inout std_logic_vector(33 downto 0);
			GPIO_1       : inout std_logic_vector(33 downto 0);
			GPIO_2       : inout std_logic_vector(12 downto 0);
        
		   GPIO_0_IN    : in    std_logic_vector(1 downto 0);
			GPIO_1_IN    : in    std_logic_vector(1 downto 0);
			GPIO_2_IN    : in    std_logic_vector(2 downto 0);
        
         -- SDRAM IS42S16160B (143MHz@CL-3) is used.
         DRAM_CLK     : out   std_logic;                       
         DRAM_CKE     : out   std_logic;    
         DRAM_CS_N    : out   std_logic;
         DRAM_RAS_N   : out   std_logic;
         DRAM_CAS_N   : out   std_logic;
         DRAM_WE_N    : out   std_logic;
         DRAM_DQ      : inout std_logic_vector(15 downto 0);
         DRAM_DQM     : out   std_logic_vector(1 downto 0);
         DRAM_ADDR    : out   std_logic_vector(12 downto 0);
         DRAM_BA      : out   std_logic_vector(1 downto 0);  
                  
         EPCS_DCLK     : out   std_logic;
         EPCS_NCSO     : out   std_logic;
         EPCS_ASDO     : out   std_logic;
         EPCS_DATA0    : in    std_logic;
                  
         LED           : out   std_logic_vector(7 downto 0);
         
         KEY           : in    std_logic_vector(1 downto 0);
         SW            : in    std_logic_vector(3 downto 0);
        
		   ADC_SDAT      : in    std_logic;
         ADC_SADDR     : out   std_logic; 
         ADC_SCLK      : out   std_logic; 
         ADC_CS_N      : out   std_logic;

		   G_SENSOR_INT  : in    std_logic;
			G_SENSOR_CS_N : out   std_logic;
			
			-- EEPROM
         I2C_SDAT      : in    std_logic; 
         I2C_SCLK      : out   std_logic          
);
end entity de0_nano_system;

architecture syn of de0_nano_system is
   component pll_sys
     port ( 
            inclk0   : in  std_logic  := '0';
            c0       : out std_logic ;
            c1       : out std_logic ;
            locked   : out std_logic 
          );
   end component pll_sys;

	component counter_div is
		generic ( OFFSET : INTEGER; BIT_WIDTH : INTEGER);
      port ( clk         : in  std_logic;
             counter_out : out std_logic_vector((BIT_WIDTH - 1) downto 0)
           );
   end component counter_div;
	
   
	component jtagtestrw is
		port ( tdi                : out std_logic;                                       
			 	 tdo                : in  std_logic                    := '0';             
				 ir_in              : out std_logic_vector(1 downto 0);                   
				 ir_out             : in  std_logic_vector(1 downto 0) := (others => '0'); 
				 virtual_state_cdr  : out std_logic;                                       
				 virtual_state_sdr  : out std_logic;                                       
				 virtual_state_e1dr : out std_logic;                                       
				 virtual_state_pdr  : out std_logic;                                       
				 virtual_state_e2dr : out std_logic;                                       
				 virtual_state_udr  : out std_logic;                                       
				 virtual_state_cir  : out std_logic;                                       
				 virtual_state_uir  : out std_logic;                                     
				 tck                : out std_logic                                        
				);
	end component jtagtestrw;
	
	component jtagif2 is
		port( tck         : in  std_logic;
				tdi         : in  std_logic;
				tdo         : out std_logic;
				aclr        : in  std_logic;
				sdr         : in  std_logic;
				udr         : in  std_logic;
				cdr         : in  std_logic;
				ir_in       : in  std_logic_vector(1 downto 0);
				ir_in_dec   : out std_logic_vector(6 downto 0);
				ir_out_v    : in  std_logic_vector(6 downto 0);
				ir_out_set  : in  std_logic;
				ir_out_done : out std_logic;
				ir_out      : out std_logic_vector(1 downto 0)
			 );
	end component jtagif2;
	
   signal clk_10     : std_logic;
   signal pll_locked : std_logic;
	
	signal tdi   : std_logic;
	signal tdo   : std_logic;
	signal tck   : std_logic;
	signal ir_in : std_logic_vector(1 downto 0);
	signal sdr   : std_logic;
	signal udr   : std_logic;
	signal cdr   : std_logic;
	
	signal test_out_data : std_logic_vector(6 downto 0);
	
begin

   inst_pll_sys : pll_sys
      port map ( inclk0 => CLOCK_50,
                 c0     => DRAM_CLK,
                 c1     => clk_10,
                 locked => pll_locked
               );
                                  
   inst_heartbeat : counter_div 
		generic map ( OFFSET => 21, BIT_WIDTH => 1)
      port map ( clk         => clk_10,
                 counter_out => LED(0 downto 0)
               );
	
   -- IR WIDTH must be 2
   inst_jtagtest : jtagtestrw
      port map ( tdi => tdi,
					  tdo => tdo,
					  ir_in => ir_in,
					  virtual_state_sdr => sdr,
					  virtual_state_udr => udr,
					  virtual_state_cdr => cdr,
                 tck => tck
               );
	
   inst_test_out : counter_div
		generic map ( OFFSET => 0, BIT_WIDTH => 7)
		port map ( clk         => sdr,
                 counter_out => test_out_data
               ); 	
					
	inst_jtag_if : jtagif2 
		port map ( 
				  tck => tck,
				  tdi => tdi,
				  tdo => tdo,
				  sdr => sdr,
				  udr => udr,
				  cdr => cdr,
				  ir_in => ir_in,
				  ir_in_dec => LED(7 downto 1),
				  aclr => '0',
				  ir_out_v => test_out_data,
				  ir_out_set => '1'
				); 
									
end architecture syn;

-- *** EOF ***