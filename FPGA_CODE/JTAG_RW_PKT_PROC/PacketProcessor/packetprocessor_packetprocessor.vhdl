-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessor_types.all;

entity packetprocessor_packetprocessor is
  port(memop           : in std_logic_vector(11 downto 0);
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       result          : out packetprocessor_types.tup3);
end;

architecture structural of packetprocessor_packetprocessor is
  signal x            : unsigned(7 downto 0);
  signal x_0          : boolean;
  signal w_app_arg    : packetprocessor_types.tup2;
  signal x_case_alt   : unsigned(10 downto 0);
  signal a            : unsigned(10 downto 0);
  signal w_app_arg_0  : std_logic_vector(19 downto 0);
  signal x_1          : unsigned(10 downto 0);
  signal x_2          : boolean;
  signal w_case_alt   : packetprocessor_types.tup3_0;
  signal w_case_alt_0 : packetprocessor_types.tup3_0;
  signal x_3          : std_logic_vector(19 downto 0);
  signal x_4          : unsigned(10 downto 0);
  signal w            : packetprocessor_types.tup3_0;
  signal result_0     : unsigned(10 downto 0);
  signal wraddr       : unsigned(10 downto 0);
  signal app_arg      : std_logic_vector(19 downto 0);
  signal app_arg_0    : unsigned(10 downto 0);
  signal app_arg_1    : boolean;
  signal app_arg_2    : unsigned(7 downto 0);
begin
  x <= unsigned(memop(10 downto 3));
  
  x_0 <= w.tup3_0_sel1;
  
  w_app_arg <= (tup2_sel0 => wraddr
               ,tup2_sel1 => x);
  
  x_case_alt <= wraddr + to_unsigned(1,11);
  
  a <= unsigned(memop(10 downto 0));
  
  w_app_arg_0 <= std_logic_vector'("1" & (std_logic_vector(w_app_arg.tup2_sel0)
                                          & std_logic_vector(w_app_arg.tup2_sel1)));
  
  with (wraddr) select
    x_1 <= to_unsigned(2047,11) when "11111111111",
           x_case_alt when others;
  
  x_2 <= x_0;
  
  w_case_alt <= (tup3_0_sel0 => to_unsigned(0,11)
                ,tup3_0_sel1 => true
                ,tup3_0_sel2 => w_app_arg_0);
  
  w_case_alt_0 <= (tup3_0_sel0 => a
                  ,tup3_0_sel1 => false
                  ,tup3_0_sel2 => std_logic_vector'("0" & "0000000000000000000"));
  
  x_3 <= w.tup3_0_sel2;
  
  x_4 <= w.tup3_0_sel0;
  
  with (memop(11 downto 11)) select
    w <= w_case_alt_0 when "0",
         w_case_alt when others;
  
  result_0 <= x_1 when x_2 else
              wraddr;
  
  -- register begin
  packetprocessor_packetprocessor_register : process(system1000,system1000_rstn)
  begin
    if system1000_rstn = '0' then
      wraddr <= to_unsigned(0,11);
    elsif rising_edge(system1000) then
      wraddr <= result_0;
    end if;
  end process;
  -- register end
  
  app_arg <= x_3;
  
  app_arg_0 <= x_4;
  
  app_arg_1 <= wraddr = to_unsigned(2047,11);
  
  packetprocessor_readnew_app_arg_2 : entity packetprocessor_readnew
    port map
      (result          => app_arg_2
      ,system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,w3              => app_arg_0
      ,w4              => app_arg);
  
  result <= (tup3_sel0 => app_arg_2
            ,tup3_sel1 => app_arg_1
            ,tup3_sel2 => app_arg_1);
end;
