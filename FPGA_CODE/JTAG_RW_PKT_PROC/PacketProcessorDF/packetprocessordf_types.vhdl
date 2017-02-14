library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package packetprocessordf_types is
  type counterstate is record
    counterstate_sel0 : unsigned(10 downto 0);
    counterstate_sel1 : unsigned(10 downto 0);
    counterstate_sel2 : unsigned(3 downto 0);
    counterstate_sel3 : unsigned(15 downto 0);
  end record;
  type tup2 is record
    tup2_sel0 : std_logic_vector(11 downto 0);
    tup2_sel1 : boolean;
  end record;
  function toSLV (slv : in std_logic_vector) return std_logic_vector;
  function toSLV (u : in unsigned) return std_logic_vector;
  function toSLV (b : in boolean) return std_logic_vector;
  function fromSLV (sl : in std_logic_vector) return boolean;
  function tagToEnum (s : in signed) return boolean;
  function dataToTag (b : in boolean) return signed;
  function toSLV (p : packetprocessordf_types.counterstate) return std_logic_vector;
  function toSLV (p : packetprocessordf_types.tup2) return std_logic_vector;
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
    return (toSLV(p.counterstate_sel0) & toSLV(p.counterstate_sel1) & toSLV(p.counterstate_sel2) & toSLV(p.counterstate_sel3));
  end;
  function toSLV (p : packetprocessordf_types.tup2) return std_logic_vector is
  begin
    return (toSLV(p.tup2_sel0) & toSLV(p.tup2_sel1));
  end;
end;
