-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessor_types.all;

entity packetprocessor_blockram is
  port(rd         : in unsigned(10 downto 0);
       wrm        : in std_logic_vector(19 downto 0);
       -- clock
       system1000 : in std_logic;
       result     : out unsigned(7 downto 0));
end;

architecture structural of packetprocessor_blockram is
  signal x2            : unsigned(10 downto 0);
  signal wild2_app_arg : signed(63 downto 0);
  signal y             : unsigned(7 downto 0);
  signal wild2         : signed(63 downto 0);
  signal x1            : packetprocessor_types.tup2_0;
  signal result_0      : signed(63 downto 0);
  signal wild_app_arg  : signed(63 downto 0);
  signal case_alt      : unsigned(7 downto 0);
  signal case_alt_0    : signed(63 downto 0);
  signal wild          : signed(63 downto 0);
  signal app_arg       : unsigned(7 downto 0);
  signal app_arg_0     : signed(63 downto 0);
  signal app_arg_1     : boolean;
  signal result_1      : signed(63 downto 0);
begin
  -- blockRam begin
  packetprocessor_blockram_blockram : block
    signal ram : packetprocessor_types.array_of_unsigned_8(0 to 2047) := (packetprocessor_types.array_of_unsigned_8'(0 to 2048-1 =>  to_unsigned(0,8) ));
    signal dout : unsigned(7 downto 0);
    signal rd_0 : integer range 0 to 2048 - 1;
    signal wr : integer range 0 to 2048 - 1;
  begin
    rd_0 <= to_integer(result_1)
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
        dout <= ram(rd_0);
      end if;
    end process;
    result <= dout;
  end block;
  -- blockRam end
  
  x2 <= x1.tup2_0_sel0;
  
  wild2_app_arg <= signed(std_logic_vector(resize(x2,64)));
  
  y <= x1.tup2_0_sel1;
  
  wild2 <= wild2_app_arg;
  
  x1 <= (tup2_0_sel0 => unsigned(wrm(18 downto 8))
        ,tup2_0_sel1 => unsigned(wrm(7 downto 0)));
  
  result_0 <= wild2;
  
  wild_app_arg <= signed(std_logic_vector(resize(rd,64)));
  
  case_alt <= y;
  
  case_alt_0 <= result_0;
  
  wild <= wild_app_arg;
  
  with (wrm(19 downto 19)) select
    app_arg <= unsigned'(0 to 7 => 'X') when "0",
               case_alt when others;
  
  with (wrm(19 downto 19)) select
    app_arg_0 <= signed'(0 to 63 => 'X') when "0",
                 case_alt_0 when others;
  
  with (wrm(19 downto 19)) select
    app_arg_1 <= false when "0",
                 true when others;
  
  result_1 <= wild;
end;
