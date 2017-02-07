library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package packetprocessor_types is
  type tup2_1 is record
    tup2_1_sel0 : boolean;
    tup2_1_sel1 : unsigned(7 downto 0);
  end record;
  type tup3 is record
    tup3_sel0 : std_logic_vector(8 downto 0);
    tup3_sel1 : boolean;
    tup3_sel2 : boolean;
  end record;
  type array_of_unsigned_8 is array (integer range <>) of unsigned(7 downto 0);
  type tup4 is record
    tup4_sel0 : unsigned(10 downto 0);
    tup4_sel1 : boolean;
    tup4_sel2 : boolean;
    tup4_sel3 : std_logic_vector(19 downto 0);
  end record;
  type tup2 is record
    tup2_sel0 : std_logic_vector(11 downto 0);
    tup2_sel1 : boolean;
  end record;
  type tup2_0 is record
    tup2_0_sel0 : unsigned(10 downto 0);
    tup2_0_sel1 : unsigned(7 downto 0);
  end record;
  function toSLV (slv : in std_logic_vector) return std_logic_vector;
  function toSLV (s : in signed) return std_logic_vector;
  function toSLV (u : in unsigned) return std_logic_vector;
  function toSLV (b : in boolean) return std_logic_vector;
  function fromSLV (sl : in std_logic_vector) return boolean;
  function tagToEnum (s : in signed) return boolean;
  function dataToTag (b : in boolean) return signed;
  function toSLV (p : packetprocessor_types.tup2_1) return std_logic_vector;
  function toSLV (p : packetprocessor_types.tup3) return std_logic_vector;
  function toSLV (value :  packetprocessor_types.array_of_unsigned_8) return std_logic_vector;
  function toSLV (p : packetprocessor_types.tup4) return std_logic_vector;
  function toSLV (p : packetprocessor_types.tup2) return std_logic_vector;
  function toSLV (p : packetprocessor_types.tup2_0) return std_logic_vector;
end;

package body packetprocessor_types is
  function toSLV (slv : in std_logic_vector) return std_logic_vector is
  begin
    return slv;
  end;
  function toSLV (s : in signed) return std_logic_vector is
  begin
    return std_logic_vector(s);
  end;
  function toSLV (u : in unsigned) return std_logic_vector is
  begin
    return std_logic_vector(u);
  end;
  function toSLV (b : in boolean) return std_logic_vector is
  begin
    if b then
      return "1";
    else
      return "0";
    end if;
  end;
  function fromSLV (sl : in std_logic_vector) return boolean is
  begin
    if sl = "1" then
      return true;
    else
      return false;
    end if;
  end;
  function tagToEnum (s : in signed) return boolean is
  begin
    if s = to_signed(0,64) then
      return false;
    else
      return true;
    end if;
  end;
  function dataToTag (b : in boolean) return signed is
  begin
    if b then
      return to_signed(1,64);
    else
      return to_signed(0,64);
    end if;
  end;
  function toSLV (p : packetprocessor_types.tup2_1) return std_logic_vector is
  begin
    return (toSLV(p.tup2_1_sel0) & toSLV(p.tup2_1_sel1));
  end;
  function toSLV (p : packetprocessor_types.tup3) return std_logic_vector is
  begin
    return (toSLV(p.tup3_sel0) & toSLV(p.tup3_sel1) & toSLV(p.tup3_sel2));
  end;
  function toSLV (value :  packetprocessor_types.array_of_unsigned_8) return std_logic_vector is
    alias ivalue    : packetprocessor_types.array_of_unsigned_8(1 to value'length) is value;
    variable result : std_logic_vector(1 to value'length * 8);
  begin
    for i in ivalue'range loop
      result(((i - 1) * 8) + 1 to i*8) := toSLV(ivalue(i));
    end loop;
    return result;
  end;
  function toSLV (p : packetprocessor_types.tup4) return std_logic_vector is
  begin
    return (toSLV(p.tup4_sel0) & toSLV(p.tup4_sel1) & toSLV(p.tup4_sel2) & toSLV(p.tup4_sel3));
  end;
  function toSLV (p : packetprocessor_types.tup2) return std_logic_vector is
  begin
    return (toSLV(p.tup2_sel0) & toSLV(p.tup2_sel1));
  end;
  function toSLV (p : packetprocessor_types.tup2_0) return std_logic_vector is
  begin
    return (toSLV(p.tup2_0_sel0) & toSLV(p.tup2_0_sel1));
  end;
end;
