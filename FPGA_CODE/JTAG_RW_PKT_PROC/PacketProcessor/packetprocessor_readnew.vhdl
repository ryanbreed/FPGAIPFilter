-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessor_types.all;

entity packetprocessor_readnew is
  port(w3              : in unsigned(10 downto 0);
       w4              : in std_logic_vector(19 downto 0);
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       result          : out unsigned(7 downto 0));
end;

architecture structural of packetprocessor_readnew is
  signal x              : boolean;
  signal x_0            : unsigned(7 downto 0);
  signal x_1            : unsigned(7 downto 0);
  signal tup            : packetprocessor_types.tup2_1;
  signal x_2            : boolean;
  signal y              : unsigned(7 downto 0);
  signal tup_app_arg    : packetprocessor_types.tup2_1;
  signal tup_case_alt   : packetprocessor_types.tup2_1;
  signal tup_case_alt_0 : packetprocessor_types.tup2_1;
  signal ds1            : packetprocessor_types.tup2_0;
  signal tup_app_arg_0  : boolean;
  signal wrdata         : unsigned(7 downto 0);
  signal wr             : unsigned(10 downto 0);
begin
  result <= x_0 when x else
            x_1;
  
  x <= x_2;
  
  x_0 <= y;
  
  packetprocessor_blockram_x_1 : entity packetprocessor_blockram
    port map
      (result     => x_1
      ,system1000 => system1000
      ,rd         => w3
      ,wrm        => w4);
  
  -- register begin
  packetprocessor_readnew_register : process(system1000,system1000_rstn)
  begin
    if system1000_rstn = '0' then
      tup <= (tup2_1_sel0 => false,tup2_1_sel1 => unsigned'(0 to 7 => 'X'));
    elsif rising_edge(system1000) then
      tup <= tup_app_arg;
    end if;
  end process;
  -- register end
  
  x_2 <= tup.tup2_1_sel0;
  
  y <= tup.tup2_1_sel1;
  
  with (w4(19 downto 19)) select
    tup_app_arg <= (tup2_1_sel0 => false
                   ,tup2_1_sel1 => unsigned'(0 to 7 => 'X')) when "0",
                   tup_case_alt when others;
  
  tup_case_alt <= tup_case_alt_0;
  
  tup_case_alt_0 <= (tup2_1_sel0 => tup_app_arg_0
                    ,tup2_1_sel1 => wrdata);
  
  ds1 <= (tup2_0_sel0 => unsigned(w4(18 downto 8))
         ,tup2_0_sel1 => unsigned(w4(7 downto 0)));
  
  tup_app_arg_0 <= wr = w3;
  
  wrdata <= ds1.tup2_0_sel1;
  
  wr <= ds1.tup2_0_sel0;
end;
