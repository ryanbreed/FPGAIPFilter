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
  signal x             : unsigned(7 downto 0);
  signal w_app_arg     : packetprocessor_types.tup2;
  signal x2            : unsigned(10 downto 0);
  signal x_0           : unsigned(10 downto 0);
  signal a             : unsigned(10 downto 0);
  signal w_app_arg_0   : std_logic_vector(19 downto 0);
  signal x_1           : boolean;
  signal wild2_app_arg : signed(63 downto 0);
  signal w_case_alt    : packetprocessor_types.tup3_0;
  signal w_case_alt_0  : packetprocessor_types.tup3_0;
  signal x_case_alt    : unsigned(10 downto 0);
  signal x_2           : std_logic_vector(19 downto 0);
  signal y             : unsigned(7 downto 0);
  signal wild2         : signed(63 downto 0);
  signal x_3           : unsigned(10 downto 0);
  signal w             : packetprocessor_types.tup3_0;
  signal x_4           : unsigned(10 downto 0);
  signal x_5           : boolean;
  signal x1            : packetprocessor_types.tup2;
  signal result_0      : signed(63 downto 0);
  signal wild_app_arg  : signed(63 downto 0);
  signal result_1      : unsigned(10 downto 0);
  signal ds            : std_logic_vector(19 downto 0);
  signal case_alt      : unsigned(7 downto 0);
  signal case_alt_0    : signed(63 downto 0);
  signal wild          : signed(63 downto 0);
  signal wraddr        : unsigned(10 downto 0);
  signal app_arg       : unsigned(7 downto 0);
  signal app_arg_0     : signed(63 downto 0);
  signal app_arg_1     : boolean;
  signal result_2      : signed(63 downto 0);
  signal app_arg_2     : boolean;
  signal result_3      : unsigned(7 downto 0);
begin
  x <= unsigned(memop(10 downto 3));
  
  w_app_arg <= (tup2_sel0 => wraddr
               ,tup2_sel1 => x);
  
  x2 <= x1.tup2_sel0;
  
  x_0 <= w.tup3_0_sel0;
  
  a <= unsigned(memop(10 downto 0));
  
  w_app_arg_0 <= std_logic_vector'("1" & (std_logic_vector(w_app_arg.tup2_sel0)
                                          & std_logic_vector(w_app_arg.tup2_sel1)));
  
  x_1 <= w.tup3_0_sel1;
  
  wild2_app_arg <= signed(std_logic_vector(resize(x2,64)));
  
  w_case_alt <= (tup3_0_sel0 => to_unsigned(0,11)
                ,tup3_0_sel1 => true
                ,tup3_0_sel2 => w_app_arg_0);
  
  w_case_alt_0 <= (tup3_0_sel0 => a
                  ,tup3_0_sel1 => false
                  ,tup3_0_sel2 => std_logic_vector'("0" & "0000000000000000000"));
  
  x_case_alt <= wraddr + to_unsigned(1,11);
  
  x_2 <= w.tup3_0_sel2;
  
  y <= x1.tup2_sel1;
  
  wild2 <= wild2_app_arg;
  
  x_3 <= x_0;
  
  with (memop(11 downto 11)) select
    w <= w_case_alt_0 when "0",
         w_case_alt when others;
  
  with (wraddr) select
    x_4 <= to_unsigned(2047,11) when "11111111111",
           x_case_alt when others;
  
  x_5 <= x_1;
  
  x1 <= (tup2_sel0 => unsigned(ds(18 downto 8))
        ,tup2_sel1 => unsigned(ds(7 downto 0)));
  
  result_0 <= wild2;
  
  wild_app_arg <= signed(std_logic_vector(resize(x_3,64)));
  
  result_1 <= x_4 when x_5 else
              wraddr;
  
  ds <= x_2;
  
  case_alt <= y;
  
  case_alt_0 <= result_0;
  
  wild <= wild_app_arg;
  
  -- register begin
  packetprocessor_packetprocessor_register : process(system1000,system1000_rstn)
  begin
    if system1000_rstn = '0' then
      wraddr <= to_unsigned(0,11);
    elsif rising_edge(system1000) then
      wraddr <= result_1;
    end if;
  end process;
  -- register end
  
  with (ds(19 downto 19)) select
    app_arg <= unsigned'(0 to 7 => 'X') when "0",
               case_alt when others;
  
  with (ds(19 downto 19)) select
    app_arg_0 <= signed'(0 to 63 => 'X') when "0",
                 case_alt_0 when others;
  
  with (ds(19 downto 19)) select
    app_arg_1 <= false when "0",
                 true when others;
  
  result_2 <= wild;
  
  app_arg_2 <= wraddr = to_unsigned(2047,11);
  
  -- blockRam begin
  packetprocessor_packetprocessor_blockram : block
    signal ram : packetprocessor_types.array_of_unsigned_8(0 to 2047) := (packetprocessor_types.array_of_unsigned_8'(0 to 2048-1 =>  to_unsigned(0,8) ));
    signal dout : unsigned(7 downto 0);
    signal rd : integer range 0 to 2048 - 1;
    signal wr : integer range 0 to 2048 - 1;
  begin
    rd <= to_integer(result_2)
    -- pragma translate_off
                  mod 2048
    -- pragma translate_on
                  ;
  
    wr <= to_integer(app_arg_0)
    -- pragma translate_off
                  mod 2048
    -- pragma translate_on
                  ;
  
    blockram_sync : process(system1000)
    begin
      if rising_edge(system1000) then
        if app_arg_1 then
          ram(wr) <= app_arg;
        end if;
        dout <= ram(rd);
      end if;
    end process;
    result_3 <= dout;
  end block;
  -- blockRam end
  
  result <= (tup3_sel0 => result_3
            ,tup3_sel1 => app_arg_2
            ,tup3_sel2 => app_arg_2);
end;
