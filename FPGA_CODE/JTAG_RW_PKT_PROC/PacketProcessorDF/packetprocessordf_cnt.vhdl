-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_cnt is
  port(s      : in packetprocessordf_types.counterstate;
       x      : in std_logic_vector(9 downto 0);
       result : out packetprocessordf_types.counterstate);
end;

architecture structural of packetprocessordf_cnt is
  signal d          : unsigned(7 downto 0);
  signal case_alt   : packetprocessordf_types.counterstate;
  signal ds3        : unsigned(15 downto 0);
  signal ds2        : unsigned(3 downto 0);
  signal ds1        : unsigned(10 downto 0);
  signal ds         : unsigned(10 downto 0);
  signal case_alt_0 : packetprocessordf_types.counterstate;
  signal app_arg    : unsigned(15 downto 0);
  signal case_alt_1 : unsigned(15 downto 0);
  signal case_alt_2 : unsigned(15 downto 0);
  signal app_arg_0  : std_logic_vector(15 downto 0);
  signal app_arg_1  : std_logic_vector(15 downto 0);
  signal app_arg_2  : std_logic_vector(15 downto 0);
  signal app_arg_3  : unsigned(3 downto 0);
  signal case_alt_3 : unsigned(3 downto 0);
  signal app_arg_4  : std_logic_vector(3 downto 0);
  signal app_arg_5  : std_logic_vector(7 downto 0);
  signal app_arg_6  : unsigned(10 downto 0);
  signal case_alt_4 : unsigned(10 downto 0);
  signal case_alt_5 : unsigned(10 downto 0);
  signal app_arg_7  : std_logic_vector(10 downto 0);
  signal app_arg_8  : std_logic_vector(15 downto 0);
  signal app_arg_9  : unsigned(15 downto 0);
  signal app_arg_10 : unsigned(10 downto 0);
begin
  with (x(9 downto 8)) select
    result <= case_alt when "00",
              (counterstate_sel0 => to_unsigned(0,11)
              ,counterstate_sel1 => to_unsigned(2047,11)
              ,counterstate_sel2 => to_unsigned(0,4)
              ,counterstate_sel3 => to_unsigned(0,16)) when "01",
              s when others;
  
  d <= unsigned(x(7 downto 0));
  
  case_alt <= case_alt_0;
  
  ds3 <= s.counterstate_sel3;
  
  ds2 <= s.counterstate_sel2;
  
  ds1 <= s.counterstate_sel1;
  
  ds <= s.counterstate_sel0;
  
  case_alt_0 <= (counterstate_sel0 => app_arg_10
                ,counterstate_sel1 => app_arg_6
                ,counterstate_sel2 => app_arg_3
                ,counterstate_sel3 => app_arg);
  
  with (ds) select
    app_arg <= case_alt_2 when "00000000010",
               case_alt_1 when "00000000011",
               ds3 when others;
  
  case_alt_1 <= unsigned(app_arg_0);
  
  case_alt_2 <= unsigned(app_arg_1);
  
  -- setSlice begin
  setslice : process(app_arg_2,app_arg_5)
    variable ivec : std_logic_vector(15 downto 0);
  begin
    ivec := app_arg_2;
    ivec(7 downto 0) := app_arg_5;
    app_arg_0 <= ivec;
  end process;
  -- setSlice end
  
  -- setSlice begin
  setslice_0 : process(app_arg_2,app_arg_5)
    variable ivec_0 : std_logic_vector(15 downto 0);
  begin
    ivec_0 := app_arg_2;
    ivec_0(15 downto 8) := app_arg_5;
    app_arg_1 <= ivec_0;
  end process;
  -- setSlice end
  
  app_arg_2 <= std_logic_vector(ds3);
  
  with (ds) select
    app_arg_3 <= case_alt_3 when "00000000000",
                 ds2 when others;
  
  case_alt_3 <= unsigned(app_arg_4);
  
  -- slice begin
  app_arg_4 <= app_arg_5(3 downto 0);
  -- slice end
  
  app_arg_5 <= std_logic_vector(d);
  
  with (ds) select
    app_arg_6 <= case_alt_4 when "00000000100",
                 case_alt_5 when others;
  
  case_alt_4 <= unsigned(app_arg_7);
  
  case_alt_5 <= ds1 - to_unsigned(1,11);
  
  -- slice begin
  app_arg_7 <= app_arg_8(10 downto 0);
  -- slice end
  
  app_arg_8 <= std_logic_vector(app_arg_9);
  
  app_arg_9 <= ds3 - to_unsigned(4,16);
  
  app_arg_10 <= ds + to_unsigned(1,11);
end;
