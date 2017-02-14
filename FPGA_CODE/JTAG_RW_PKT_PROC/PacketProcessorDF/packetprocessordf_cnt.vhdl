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
       x      : in std_logic_vector(28 downto 0);
       result : out packetprocessordf_types.counterstate);
end;

architecture structural of packetprocessordf_cnt is
  signal case_alt      : packetprocessordf_types.counterstate;
  signal case_alt_0    : packetprocessordf_types.counterstate;
  signal case_alt_1    : packetprocessordf_types.counterstate;
  signal app_arg       : unsigned(10 downto 0);
  signal app_arg_0     : unsigned(10 downto 0);
  signal app_arg_1     : unsigned(3 downto 0);
  signal app_arg_2     : unsigned(15 downto 0);
  signal app_arg_3     : std_logic_vector(8 downto 0);
  signal app_arg_4     : boolean;
  signal app_arg_5     : packetprocessordf_types.array_of_tup3(0 to 3);
  signal app_arg_6     : unsigned(1 downto 0);
  signal app_arg_7     : boolean;
  signal case_alt_2    : packetprocessordf_types.counterstate;
  signal case_alt_3    : packetprocessordf_types.counterstate;
  signal case_alt_4    : unsigned(10 downto 0);
  signal case_alt_5    : unsigned(10 downto 0);
  signal case_alt_6    : unsigned(3 downto 0);
  signal case_alt_7    : unsigned(15 downto 0);
  signal case_alt_8    : std_logic_vector(8 downto 0);
  signal case_alt_9    : boolean;
  signal result_0      : packetprocessordf_types.array_of_tup3(0 to 3);
  signal app_arg_8     : unsigned(1 downto 0);
  signal ds            : unsigned(10 downto 0);
  signal ds1           : unsigned(10 downto 0);
  signal ds2           : unsigned(3 downto 0);
  signal ds3           : unsigned(15 downto 0);
  signal ds4           : std_logic_vector(8 downto 0);
  signal ds5           : boolean;
  signal ds8           : boolean;
  signal app_arg_9     : boolean;
  signal ds6           : packetprocessordf_types.array_of_tup3(0 to 3);
  signal ds7           : unsigned(1 downto 0);
  signal case_alt_10   : unsigned(10 downto 0);
  signal case_alt_11   : unsigned(10 downto 0);
  signal case_alt_12   : unsigned(3 downto 0);
  signal case_alt_13   : unsigned(15 downto 0);
  signal case_alt_14   : unsigned(15 downto 0);
  signal case_scrut    : boolean;
  signal case_alt_15   : std_logic_vector(8 downto 0);
  signal case_alt_16   : boolean;
  signal app_arg_10    : signed(63 downto 0);
  signal app_arg_11    : packetprocessordf_types.tup3;
  signal app_arg_12    : std_logic_vector(10 downto 0);
  signal app_arg_13    : std_logic_vector(3 downto 0);
  signal app_arg_14    : std_logic_vector(15 downto 0);
  signal app_arg_15    : std_logic_vector(15 downto 0);
  signal result_1      : boolean;
  signal case_scrut_0  : packetprocessordf_types.tup3;
  signal wild3         : signed(63 downto 0);
  signal d             : unsigned(7 downto 0);
  signal pos           : unsigned(10 downto 0);
  signal mask          : unsigned(7 downto 0);
  signal val           : unsigned(7 downto 0);
  signal app_arg_16    : std_logic_vector(15 downto 0);
  signal app_arg_17    : std_logic_vector(7 downto 0);
  signal app_arg_18    : std_logic_vector(15 downto 0);
  signal case_scrut_1  : boolean;
  signal case_alt_17   : boolean;
  signal cnt_jout      : boolean;
  signal wild3_app_arg : signed(63 downto 0);
  signal app_arg_19    : unsigned(15 downto 0);
  signal case_scrut_2  : boolean;
  signal a             : unsigned(10 downto 0);
  signal app_arg_20    : unsigned(7 downto 0);
  signal p             : unsigned(7 downto 0);
  signal m             : unsigned(7 downto 0);
begin
  case_alt <= (counterstate_sel0 => app_arg
              ,counterstate_sel1 => app_arg_0
              ,counterstate_sel2 => app_arg_1
              ,counterstate_sel3 => app_arg_2
              ,counterstate_sel4 => app_arg_3
              ,counterstate_sel5 => app_arg_4
              ,counterstate_sel6 => app_arg_5
              ,counterstate_sel7 => app_arg_6
              ,counterstate_sel8 => app_arg_7);
  
  case_alt_0 <= case_alt_2;
  
  case_alt_1 <= case_alt_3;
  
  app_arg <= case_alt_4;
  
  app_arg_0 <= case_alt_5;
  
  app_arg_1 <= case_alt_6;
  
  app_arg_2 <= case_alt_7;
  
  app_arg_3 <= case_alt_8;
  
  app_arg_4 <= app_arg_9;
  
  app_arg_5 <= ds6;
  
  app_arg_6 <= ds7;
  
  app_arg_7 <= case_alt_9;
  
  case_alt_2 <= (counterstate_sel0 => ds
                ,counterstate_sel1 => ds1
                ,counterstate_sel2 => ds2
                ,counterstate_sel3 => ds3
                ,counterstate_sel4 => ds4
                ,counterstate_sel5 => ds5
                ,counterstate_sel6 => result_0
                ,counterstate_sel7 => app_arg_8
                ,counterstate_sel8 => ds8);
  
  case_alt_3 <= (counterstate_sel0 => ds
                ,counterstate_sel1 => ds1
                ,counterstate_sel2 => ds2
                ,counterstate_sel3 => ds3
                ,counterstate_sel4 => ds4
                ,counterstate_sel5 => app_arg_9
                ,counterstate_sel6 => ds6
                ,counterstate_sel7 => ds7
                ,counterstate_sel8 => ds8);
  
  case_alt_4 <= ds + to_unsigned(1,11);
  
  with (ds) select
    case_alt_5 <= case_alt_11 when "00000000100",
                  case_alt_10 when others;
  
  with (ds) select
    case_alt_6 <= case_alt_12 when "00000000000",
                  ds2 when others;
  
  with (ds) select
    case_alt_7 <= case_alt_13 when "00000000010",
                  case_alt_14 when "00000000011",
                  ds3 when others;
  
  case_alt_8 <= case_alt_15 when case_scrut else
                std_logic_vector'("0" & "00000000");
  
  case_alt_9 <= true when ds8 else
                case_alt_16;
  
  -- replace begin
  replacevec : block
    signal vec_index : integer range 0 to 4-1;
  begin
    vec_index <= to_integer(app_arg_10)
    -- pragma translate_off
                 mod 4
    -- pragma translate_on
                 ;
  
    process(vec_index,ds6,app_arg_11)
      variable ivec : packetprocessordf_types.array_of_tup3(0 to 3);
    begin
      ivec := ds6;
      ivec(vec_index) := app_arg_11;
      result_0 <= ivec;
    end process;
  end block;
  -- replace end
  
  app_arg_8 <= ds7 + to_unsigned(1,2);
  
  ds <= s.counterstate_sel0;
  
  ds1 <= s.counterstate_sel1;
  
  ds2 <= s.counterstate_sel2;
  
  ds3 <= s.counterstate_sel3;
  
  ds4 <= s.counterstate_sel4;
  
  ds5 <= s.counterstate_sel5;
  
  ds8 <= s.counterstate_sel8;
  
  app_arg_9 <= ds1 = to_unsigned(0,11);
  
  ds6 <= s.counterstate_sel6;
  
  ds7 <= s.counterstate_sel7;
  
  case_alt_10 <= ds1 - to_unsigned(1,11);
  
  case_alt_11 <= unsigned(app_arg_12);
  
  case_alt_12 <= unsigned(app_arg_13);
  
  case_alt_13 <= unsigned(app_arg_14);
  
  case_alt_14 <= unsigned(app_arg_15);
  
  case_scrut <= ds1 /= to_unsigned(0,11);
  
  case_alt_15 <= std_logic_vector'("1" & std_logic_vector(d));
  
  case_alt_16 <= result_1;
  
  app_arg_10 <= wild3;
  
  app_arg_11 <= (tup3_sel0 => pos
                ,tup3_sel1 => mask
                ,tup3_sel2 => val);
  
  -- slice begin
  app_arg_12 <= app_arg_16(10 downto 0);
  -- slice end
  
  -- slice begin
  app_arg_13 <= app_arg_17(3 downto 0);
  -- slice end
  
  -- setSlice begin
  setslice : process(app_arg_18,app_arg_17)
    variable ivec_0 : std_logic_vector(15 downto 0);
  begin
    ivec_0 := app_arg_18;
    ivec_0(15 downto 8) := app_arg_17;
    app_arg_14 <= ivec_0;
  end process;
  -- setSlice end
  
  -- setSlice begin
  setslice_0 : process(app_arg_18,app_arg_17)
    variable ivec_1 : std_logic_vector(15 downto 0);
  begin
    ivec_1 := app_arg_18;
    ivec_1(7 downto 0) := app_arg_17;
    app_arg_15 <= ivec_1;
  end process;
  -- setSlice end
  
  result_1 <= cnt_jout when case_scrut_1 else
              case_alt_17;
  
  -- index begin
  indexvec : block 
    signal vec_index_0 : integer range 0 to 4-1;
  begin
    vec_index_0 <= to_integer(to_signed(0,64))
    -- pragma translate_off
                 mod 4
    -- pragma translate_on
                 ;
    case_scrut_0 <= ds6(vec_index_0);
  end block;
  -- index end
  
  wild3 <= wild3_app_arg;
  
  d <= unsigned(x(26 downto 19));
  
  pos <= unsigned(x(26 downto 16));
  
  mask <= unsigned(x(15 downto 8));
  
  val <= unsigned(x(7 downto 0));
  
  app_arg_16 <= std_logic_vector(app_arg_19);
  
  app_arg_17 <= std_logic_vector(d);
  
  app_arg_18 <= std_logic_vector(ds3);
  
  case_scrut_1 <= ds /= a;
  
  case_alt_17 <= true when case_scrut_2 else
                 cnt_jout;
  
  packetprocessordf_cnt_j_cnt_jout : entity packetprocessordf_cnt_j
    port map
      (result => cnt_jout
      ,pts    => ds6
      ,pts_0  => ds
      ,pts_1  => d);
  
  wild3_app_arg <= signed(std_logic_vector(resize(ds7,64)));
  
  app_arg_19 <= ds3 - to_unsigned(5,16);
  
  case_scrut_2 <= app_arg_20 = p;
  
  a <= case_scrut_0.tup3_sel0;
  
  app_arg_20 <= d and m;
  
  p <= case_scrut_0.tup3_sel2;
  
  m <= case_scrut_0.tup3_sel1;
  
  with (x(28 downto 27)) select
    result <= case_alt when "00",
              case_alt_0 when "01",
              (counterstate_sel0 => to_unsigned(0,11)
              ,counterstate_sel1 => to_unsigned(2047,11)
              ,counterstate_sel2 => to_unsigned(0,4)
              ,counterstate_sel3 => to_unsigned(0,16)
              ,counterstate_sel4 => std_logic_vector'("0" & "00000000")
              ,counterstate_sel5 => false
              ,counterstate_sel6 => packetprocessordf_types.array_of_tup3'((tup3_sel0 => to_unsigned(2047,11)
                                                                           ,tup3_sel1 => to_unsigned(0,8)
                                                                           ,tup3_sel2 => to_unsigned(0,8))
                                                                          ,(tup3_sel0 => to_unsigned(2047,11)
                                                                           ,tup3_sel1 => to_unsigned(0,8)
                                                                           ,tup3_sel2 => to_unsigned(0,8))
                                                                          ,(tup3_sel0 => to_unsigned(2047,11)
                                                                           ,tup3_sel1 => to_unsigned(0,8)
                                                                           ,tup3_sel2 => to_unsigned(0,8))
                                                                          ,(tup3_sel0 => to_unsigned(2047,11)
                                                                           ,tup3_sel1 => to_unsigned(0,8)
                                                                           ,tup3_sel2 => to_unsigned(0,8)))
              ,counterstate_sel7 => to_unsigned(0,2)
              ,counterstate_sel8 => false) when "10",
              case_alt_1 when others;
end;
