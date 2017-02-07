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
       en              : in boolean;
       -- clock
       system1000      : in std_logic;
       -- asynchronous reset: active low
       system1000_rstn : in std_logic;
       result          : out packetprocessor_types.tup3);
end;

architecture structural of packetprocessor_packetprocessor is
  signal ipv          : unsigned(7 downto 0);
  signal w_app_arg    : packetprocessor_types.tup2_0;
  signal x            : boolean;
  signal w_app_arg_0  : std_logic_vector(19 downto 0);
  signal x_0          : std_logic_vector(19 downto 0);
  signal x_1          : unsigned(10 downto 0);
  signal x_case_alt   : unsigned(10 downto 0);
  signal a            : unsigned(10 downto 0);
  signal w_case_alt   : packetprocessor_types.tup4;
  signal x_2          : unsigned(10 downto 0);
  signal x_3          : boolean;
  signal w_case_alt_0 : packetprocessor_types.tup4;
  signal w_case_alt_1 : packetprocessor_types.tup4;
  signal x_4          : boolean;
  signal x_app_arg    : std_logic_vector(19 downto 0);
  signal x_app_arg_0  : unsigned(10 downto 0);
  signal w            : packetprocessor_types.tup4;
  signal result_0     : unsigned(10 downto 0);
  signal x_5          : unsigned(7 downto 0);
  signal wraddr       : unsigned(10 downto 0);
  signal x_6          : boolean;
  signal case_alt     : std_logic_vector(8 downto 0);
  signal app_arg      : boolean;
  signal result_1     : std_logic_vector(8 downto 0);
begin
  ipv <= unsigned(memop(10 downto 3));
  
  w_app_arg <= (tup2_0_sel0 => wraddr
               ,tup2_0_sel1 => ipv);
  
  x <= w.tup4_sel1;
  
  w_app_arg_0 <= std_logic_vector'("1" & (std_logic_vector(w_app_arg.tup2_0_sel0)
                                          & std_logic_vector(w_app_arg.tup2_0_sel1)));
  
  x_0 <= w.tup4_sel3;
  
  x_1 <= w.tup4_sel0;
  
  x_case_alt <= wraddr + to_unsigned(1,11);
  
  a <= unsigned(memop(10 downto 0));
  
  w_case_alt <= (tup4_sel0 => to_unsigned(0,11)
                ,tup4_sel1 => true
                ,tup4_sel2 => true
                ,tup4_sel3 => w_app_arg_0);
  
  with (wraddr) select
    x_2 <= to_unsigned(2047,11) when "11111111111",
           x_case_alt when others;
  
  x_3 <= x;
  
  w_case_alt_0 <= w_case_alt when en else
                  (tup4_sel0 => to_unsigned(0,11)
                  ,tup4_sel1 => false
                  ,tup4_sel2 => false
                  ,tup4_sel3 => std_logic_vector'("0" & "0000000000000000000"));
  
  w_case_alt_1 <= (tup4_sel0 => a
                  ,tup4_sel1 => false
                  ,tup4_sel2 => true
                  ,tup4_sel3 => std_logic_vector'("0" & "0000000000000000000"));
  
  x_4 <= w.tup4_sel2;
  
  x_app_arg <= x_0;
  
  x_app_arg_0 <= x_1;
  
  with (memop(11 downto 11)) select
    w <= w_case_alt_1 when "0",
         w_case_alt_0 when others;
  
  result_0 <= x_2 when x_3 else
              wraddr;
  
  packetprocessor_readnew_x_5 : entity packetprocessor_readnew
    port map
      (result          => x_5
      ,system1000      => system1000
      ,system1000_rstn => system1000_rstn
      ,w3              => x_app_arg_0
      ,w4              => x_app_arg);
  
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
  
  x_6 <= x_4;
  
  case_alt <= std_logic_vector'("1" & std_logic_vector(x_5));
  
  app_arg <= wraddr = to_unsigned(2047,11);
  
  result_1 <= case_alt when x_6 else
              std_logic_vector'("0" & "00000000");
  
  result <= (tup3_sel0 => result_1
            ,tup3_sel1 => app_arg
            ,tup3_sel2 => app_arg);
end;
