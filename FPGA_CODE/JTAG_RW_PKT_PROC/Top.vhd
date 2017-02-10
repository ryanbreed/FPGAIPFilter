library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity de0_nano_system is
	port
		( CLOCK_50      : in  std_logic
		
		; GPIO_0        : inout std_logic_vector(33 downto 0)
		; GPIO_1        : inout std_logic_vector(33 downto 0)
      -- Removed for logic analyser GPIO_2       : inout std_logic_vector(12 downto 0);
      
		; GPIO_0_IN     : in    std_logic_vector(1 downto 0)
		; GPIO_1_IN     : in    std_logic_vector(1 downto 0)
		; GPIO_2_IN     : in    std_logic_vector(2 downto 0)
        
      -- SDRAM IS42S16160B (143MHz@CL-3) is used.
      ; DRAM_CLK      : out   std_logic
		; DRAM_CKE      : out   std_logic
		; DRAM_CS_N     : out   std_logic
		; DRAM_RAS_N    : out   std_logic
		; DRAM_CAS_N    : out   std_logic
		; DRAM_WE_N     : out   std_logic
		; DRAM_DQ       : inout std_logic_vector(15 downto 0)
		; DRAM_DQM      : out   std_logic_vector(1 downto 0)
		; DRAM_ADDR     : out   std_logic_vector(12 downto 0)
		; DRAM_BA       : out   std_logic_vector(1 downto 0)
		
		; EPCS_DCLK     : out   std_logic
		; EPCS_NCSO     : out   std_logic
		; EPCS_ASDO     : out   std_logic
		; EPCS_DATA0    : in    std_logic
		
		; LED           : out   std_logic_vector(7 downto 0)
		; KEY           : in    std_logic_vector(1 downto 0)
		; SW            : in    std_logic_vector(3 downto 0)
		
		; ADC_SDAT      : in    std_logic
		; ADC_SADDR     : out   std_logic
		; ADC_SCLK      : out   std_logic
		; ADC_CS_N      : out   std_logic
		
		; G_SENSOR_INT  : in    std_logic
		; G_SENSOR_CS_N : out   std_logic
         
      -- EEPROM
      ; I2C_SDAT      : in    std_logic
		; I2C_SCLK      : out   std_logic          
);
end entity de0_nano_system;

architecture syn of de0_nano_system is
	
	component pll_sys
		port 
			( inclk0   : in  std_logic  := '0'
			; c0       : out std_logic 
			; c1       : out std_logic
			; locked   : out std_logic 
         );
   end component pll_sys;
        
   component jtagtestrw is
      port 
			( tdi                : out std_logic
			; tdo                : in  std_logic                    := '0'
			; ir_in              : out std_logic_vector(2 downto 0)
			; ir_out             : in  std_logic_vector(2 downto 0) := (others => '0')
			; virtual_state_cdr  : out std_logic
			; virtual_state_sdr  : out std_logic
			; virtual_state_e1dr : out std_logic
			; virtual_state_pdr  : out std_logic
			; virtual_state_e2dr : out std_logic
			; virtual_state_udr  : out std_logic
			; virtual_state_cir  : out std_logic
			; virtual_state_uir  : out std_logic
			; tck                : out std_logic                                        
         );
   end component jtagtestrw;
   
	signal sys_clk     : std_logic;
   signal clk_10      : std_logic;
   signal pll_locked  : std_logic;
   
   signal tdi         : std_logic;
   signal tdo         : std_logic;
   signal tck         : std_logic;
   signal ir_in       : std_logic_vector(2 downto 0);
   signal sdr         : std_logic;
   signal udr         : std_logic;
   signal cdr         : std_logic;
	
	signal vdr_out     : std_logic_vector(11 downto 0);
	signal vdr_out_rdy : std_logic;
	signal vdr_in      : std_logic_vector(11 downto 0);
	
	signal dbg_data    : std_logic_vector(15 downto 0);
	signal dbg_clk     : std_logic;
	signal dbg_trg     : std_logic;
	
	signal pp_reset    : std_logic;
	
	function to_stdulogic( V: Boolean ) return std_ulogic is 
	begin 
		 if V then 
			  return '1'; 
		 else 
			  return '0'; 
		 end if;
	end to_stdulogic;
	
	function to_Boolean( V: std_ulogic ) return Boolean is 
	begin 
		 if V = '1' then 
			  return True; 
		 else 
			  return False; 
		 end if;
	end to_Boolean;
   
begin

   inst_pll_sys : pll_sys
      port map 
			( inclk0 => CLOCK_50
			, c0     => sys_clk
			, c1     => clk_10
			, locked => pll_locked
         );
                                  
   inst_heartbeat : counter_div 
      generic map 
			( OFFSET    => 21
			, BIT_WIDTH => 1
			)
      port map 
			( clk         => clk_10
			, counter_out => LED(0 downto 0)
         );
	
   -- IR WIDTH must be 3
   inst_jtagtest : jtagtestrw
      port map 
			( tdi               => tdi
			, tdo               => tdo
			, ir_in             => ir_in
			, virtual_state_sdr => sdr
			, virtual_state_udr => udr
			, virtual_state_cdr => cdr
			, tck               => tck
         );
               
   inst_jtag_if : jtagif2 
      generic map 
			( DR_BITS => 12 )
      port map 
			( aclr        => '0'
			, tck         => tck
			, tdi         => tdi
			, tdo         => tdo
			, sdr         => sdr
			, udr         => udr
			, cdr         => cdr
			, ir_in       => ir_in
			, vdr_out     => vdr_out
			, vdr_out_rdy => vdr_out_rdy
			, vdr_in      => vdr_in
         -- , vdr_in_rdy
         ); 
				
	inst_pp_reset : counter_hold 
      generic map 
			( HOLD_FOR => 4 )
      port map 
			( clk      => tck and pll_locked
			, hold_out => pp_reset
         );

	inst_pkt_proc : packetprocessor_topentity
		port map 
			( input_0_0                     => vdr_out
			, input_0_1                     => to_Boolean(vdr_out_rdy)
			-- clock
			, system1000                    => not tck
			-- asynchronous reset: active low
			, system1000_rstn               => pp_reset
			, std_logic_vector(output_0_0)  => vdr_in(11 downto 3)
			, to_stdulogic(output_0_1)      => vdr_in(2)
			, to_stdulogic(output_0_2)      => vdr_in(1)
			);
	  
	inst_dbgsnap : dbgsnap
		port map 
			( clk => dbg_clk
			, tr => dbg_trg
			, dbg_in => dbg_data 
			);	  
			
	dbg_clk <= (sys_clk) and pll_locked and pp_reset;
	dbg_data <= vdr_out & tck & sdr & cdr & udr;
	dbg_trg <= udr;

	LED(7 downto 1) <= vdr_in(10 downto 4);

	vdr_in(0 downto 0) <= "0";
                           
end architecture syn;

-- *** EOF ***