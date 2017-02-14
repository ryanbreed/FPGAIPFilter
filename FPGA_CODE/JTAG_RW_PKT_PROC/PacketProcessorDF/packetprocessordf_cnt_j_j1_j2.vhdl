-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.packetprocessordf_types.all;

entity packetprocessordf_cnt_j_j1_j2 is
  port(pts    : in packetprocessordf_types.array_of_tup3(0 to 3);
       pts_0  : in unsigned(10 downto 0);
       pts_1  : in unsigned(7 downto 0);
       result : out boolean);
end;

architecture structural of packetprocessordf_cnt_j_j1_j2 is
  signal app_arg      : unsigned(7 downto 0);
  signal case_scrut   : boolean;
  signal case_alt     : boolean;
  signal case_scrut_0 : packetprocessordf_types.tup3;
  signal case_alt_0   : boolean;
  signal a3           : unsigned(10 downto 0);
  signal m3           : unsigned(7 downto 0);
  signal p3           : unsigned(7 downto 0);
begin
  app_arg <= pts_1 and m3;
  
  case_scrut <= pts_0 /= a3;
  
  case_alt <= app_arg = p3;
  
  -- index begin
  indexvec : block 
    signal vec_index : integer range 0 to 4-1;
  begin
    vec_index <= to_integer(to_signed(3,64))
    -- pragma translate_off
                 mod 4
    -- pragma translate_on
                 ;
    case_scrut_0 <= pts(vec_index);
  end block;
  -- index end
  
  case_alt_0 <= false when case_scrut else
                case_alt;
  
  a3 <= case_scrut_0.tup3_sel0;
  
  m3 <= case_scrut_0.tup3_sel1;
  
  p3 <= case_scrut_0.tup3_sel2;
  
  result <= case_alt_0;
end;
