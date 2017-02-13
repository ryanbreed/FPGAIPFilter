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
	
	component clckctrl is
		port (
			inclk  : in  std_logic := 'X'; -- inclk
			ena    : in  std_logic := 'X'; -- ena
			outclk : out std_logic         -- outclk
		);
	end component clckctrl;
   
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
	signal dbg_rst_in  : std_logic;
	
	signal pp_reset    : std_logic;
	signal pp_rst_in   : std_logic;
	
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
	
-- IR WIDTH must be 3 at the moment.

-- For addressing VIR and sizing data for the virtual JTAG you can observe the 

-- Compilation Report/Analysis and Synthesis/Debug settings summary/Virtual JTAG settings
-- Which give parameters that are used in JtagRW.hs (#nastyhack for now) 
-- 	virAddrLen <= "User DR1 Length"
-- 	virAddrLen <= " Address"
--    and likely the 0xE, 0xC - TBC 

-- Can also get those parameters via TCL
-- 	open_device -hardware_name {USB-Blaster [1-1]}  -device_name {@1: EP3C25/EP4CE22 (0x020F30DD)}
--		device_lock -timeout 10000
--		device_virtual_ir_shift -instance_index 0 -ir_value 1 -show_equivalent_device_ir_dr_shift
--
--Info (16701): device_ir_shift -ir_value 14
--Info (16701): device_dr_shift -length 12 -dr_value 00B -value_in_hex
--Info (16701): device_dr_shift -length 12 -dr_value 401 -value_in_hex

-- These can be interogated from the FPGA - problem for later. 

-- These change parameters as more JTAG components are added/removed 
-- Such as:
--   * virtual JTAG
--   * extractable RAM
--   * Signal II analyser

-- Note: the clash generated RAM can not be made readable as is already dual port.

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
			
	--  synchroniser on the pll_locked	
	inst_pp_clk : clckctrl
		port map (
			inclk  => tck,
			ena    => pll_locked,
			outclk => pp_rst_in
		);
	 
	inst_pp_reset : counter_hold 
      generic map 
			( HOLD_FOR => 4 )
      port map 
			( clk      => pp_rst_in
			, hold_out => pp_reset
         );

	inst_pkt_proc : packetprocessor_topentity
		port map 
			( input_0_0                     => vdr_out
			, input_0_1                     => to_Boolean(vdr_out_rdy)
			-- clock
			, system1000                    => tck
			-- asynchronous reset: active low
			, system1000_rstn               => pp_reset
			, std_logic_vector(output_0_0)  => vdr_in(11 downto 3)
			, to_stdulogic(output_0_1)      => vdr_in(2)
			, to_stdulogic(output_0_2)      => vdr_in(1)
			);
			
	inst_pkt_proc2 : packetprocessordf_topentity
		port map 
			( input_0_0                     => vdr_out
			, input_0_1                     => to_Boolean(vdr_out_rdy)
			-- clock
			, system1000                    => tck
			-- asynchronous reset: active low
			, system1000_rstn               => pp_reset
			--, std_logic_vector(output_0_0)  => dbg_data(15 downto 5)
			, std_logic_vector(output_0_1)  => dbg_data(15 downto 5)
			, std_logic_vector(output_0_2)  => dbg_data(4 downto 1)
			--, std_logic_vector(output_0_3)  => dbg_data(1)
			);
		 
	  
--	Since we can't actively use the Signal2 logic analyser whilst using 
--	Jtag for data we can capture some events here and extract when the 
--	Jtag is done. Not pretty but works OK. See runMemGet.sh at top level.

-- tcl:
--		begin_memory_edit -hardware_name "USB-Blaster \[1-1\]" -device_name "@1: EP3C25/EP4CE22 (0x020F30DD)"
--		puts [read_content_from_memory -instance_index 0 -start_address 0 -word_count 8192 -content_in_hex]
--		end_memory_edit

	inst_ds_clk : clckctrl
		port map (
			inclk  => sys_clk,
			ena    => pll_locked,
			outclk => dbg_clk
		);
		
	inst_dbgsnap : dbgsnap
		port map 
			( clk => dbg_clk
			, tr => dbg_trg
			, dbg_in => dbg_data 
			);	  
	-- Just for testing...
	-- dbg_data <= vdr_out & tck & sdr & cdr & udr;
	dbg_trg <= udr;

	LED(7 downto 1) <= vdr_in(10 downto 4);

	vdr_in(0 downto 0) <= "0";
                           
end architecture syn;

-- *** EOF ***