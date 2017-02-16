library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package packetprocessordf_types is
  type tup3 is record
    tup3_sel0 : unsigned(10 downto 0);
    tup3_sel1 : unsigned(7 downto 0);
    tup3_sel2 : unsigned(7 downto 0);
  end record;
  type array_of_tup3 is array (integer range <>) of packetprocessordf_types.tup3;
  type counterstate is record
    counterstate_sel0 : unsigned(10 downto 0);
    counterstate_sel1 : unsigned(10 downto 0);
    counterstate_sel2 : unsigned(3 downto 0);
    counterstate_sel3 : unsigned(15 downto 0);
    counterstate_sel4 : std_logic_vector(8 downto 0);
    counterstate_sel5 : boolean;
    counterstate_sel6 : packetprocessordf_types.array_of_tup3(0 to 3);
    counterstate_sel7 : unsigned(1 downto 0);
    counterstate_sel8 : boolean;
  end record;
  type tup2_0 is record
    tup2_0_sel0 : packetprocessordf_types.counterstate;
    tup2_0_sel1 : boolean;
  end record;
  type tup2 is record
    tup2_sel0 : std_logic_vector(28 downto 0);
    tup2_sel1 : boolean;
  end record;
  type array_of_counterstate is array (integer range <>) of packetprocessordf_types.counterstate;
  function toSLV (slv : in std_logic_vector) return std_logic_vector;
  function toSLV (u : in unsigned) return std_logic_vector;
  function toSLV (p : packetprocessordf_types.tup3) return std_logic_vector;
  function toSLV (value :  packetprocessordf_types.array_of_tup3) return std_logic_vector;
  function toSLV (b : in boolean) return std_logic_vector;
  function fromSLV (sl : in std_logic_vector) return boolean;
  function tagToEnum (s : in signed) return boolean;
  function dataToTag (b : in boolean) return signed;
  function toSLV (p : packetprocessordf_types.counterstate) return std_logic_vector;
  function toSLV (p : packetprocessordf_types.tup2_0) return std_logic_vector;
  function toSLV (s : in signed) return std_logic_vector;
  function toSLV (p : packetprocessordf_types.tup2) return std_logic_vector;
  function toSLV (value :  packetprocessordf_types.array_of_counterstate) return std_logic_vector;
end;

package body packetprocessordf_types is
  function toSLV (slv : in std_logic_vector) return std_logic_vector is
  begin
    return slv;
  end;
  function toSLV (u : in unsigned) return std_logic_vector is
  begin
    return std_logic_vector(u);
  end;
  function toSLV (p : packetprocessordf_types.tup3) return std_logic_vector is
  begin
    return (toSLV(p.tup3_sel0) & toSLV(p.tup3_sel1) & toSLV(p.tup3_sel2));
  end;
  function toSLV (value :  packetprocessordf_types.array_of_tup3) return std_logic_vector is
    alias ivalue    : packetprocessordf_types.array_of_tup3(1 to value'length) is value;
    variable result : std_logic_vector(1 to value'length * 27);
  begin
    for i in ivalue'range loop
      result(((i - 1) * 27) + 1 to i*27) := toSLV(ivalue(i));
    end loop;
    return result;
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
  function toSLV (p : packetprocessordf_types.counterstate) return std_logic_vector is
  begin
    return (toSLV(p.counterstate_sel0) & toSLV(p.counterstate_sel1) & toSLV(p.counterstate_sel2) & toSLV(p.counterstate_sel3) & toSLV(p.counterstate_sel4) & toSLV(p.counterstate_sel5) & toSLV(p.counterstate_sel6) & toSLV(p.counterstate_sel7) & toSLV(p.counterstate_sel8));
  end;
  function toSLV (p : packetprocessordf_types.tup2_0) return std_logic_vector is
  begin
    return (toSLV(p.tup2_0_sel0) & toSLV(p.tup2_0_sel1));
  end;
  function toSLV (s : in signed) return std_logic_vector is
  begin
    return std_logic_vector(s);
  end;
  function toSLV (p : packetprocessordf_types.tup2) return std_logic_vector is
  begin
    return (toSLV(p.tup2_sel0) & toSLV(p.tup2_sel1));
  end;
  function toSLV (value :  packetprocessordf_types.array_of_counterstate) return std_logic_vector is
    alias ivalue    : packetprocessordf_types.array_of_counterstate(1 to value'length) is value;
    variable result : std_logic_vector(1 to value'length * 163);
  begin
    for i in ivalue'range loop
      result(((i - 1) * 163) + 1 to i*163) := toSLV(ivalue(i));
    end loop;
    return result;
  end;
end;
