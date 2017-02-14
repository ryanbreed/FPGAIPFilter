-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_cnt_j is
  port(pts    : in packetprocessordf_types.array_of_tup3(0 to 3);
       pts_0  : in unsigned(10 downto 0);
       pts_1  : in unsigned(7 downto 0);
       result : out boolean);
end;

architecture structural of packetprocessordf_cnt_j is
  signal app_arg      : unsigned(7 downto 0);
  signal case_scrut   : boolean;
  signal case_scrut_0 : boolean;
  signal case_alt     : boolean;
  signal cnt_j_j1out  : boolean;
  signal result_0     : boolean;
  signal case_scrut_1 : packetprocessordf_types.tup3;
  signal a1           : unsigned(10 downto 0);
  signal m1           : unsigned(7 downto 0);
  signal p1           : unsigned(7 downto 0);
begin
  app_arg <= pts_1 and m1;
  
  case_scrut <= app_arg = p1;
  
  case_scrut_0 <= pts_0 /= a1;
  
  case_alt <= true when case_scrut else
              cnt_j_j1out;
  
  packetprocessordf_cnt_j_j1_cnt_j_j1out : entity packetprocessordf_cnt_j_j1
    port map
      (result => cnt_j_j1out
      ,pts    => pts
      ,pts_0  => pts_0
      ,pts_1  => pts_1);
  
  result_0 <= cnt_j_j1out when case_scrut_0 else
              case_alt;
  
  -- index begin
  indexvec : block 
    signal vec_index : integer range 0 to 4-1;
  begin
    vec_index <= to_integer(to_signed(1,64))
    -- pragma translate_off
                 mod 4
    -- pragma translate_on
                 ;
    case_scrut_1 <= pts(vec_index);
  end block;
  -- index end
  
  a1 <= case_scrut_1.tup3_sel0;
  
  m1 <= case_scrut_1.tup3_sel1;
  
  p1 <= case_scrut_1.tup3_sel2;
  
  result <= result_0;
end;
