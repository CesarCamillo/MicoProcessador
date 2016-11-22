-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 07out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ESTE ARQUIVO NAO PODE SER ALTERADO


library ieee; use ieee.std_logic_1164.all; use IEEE.numeric_std.all;
library std;  use std.textio.all;
package p_WIRES is -- tipos para os barramentos e sinais

  constant t_clock_period : time := 1 ns;

  constant simulate_time : integer := 0;  -- 1 para simular com tempo != zero

  constant t_inv  : time := simulate_time*15.0 ps;
  constant t_and2 : time := simulate_time*22.0 ps;
  constant t_and3 : time := simulate_time*26.6 ps;
  constant t_and4 : time := simulate_time*33.2 ps;
  constant t_and5 : time := simulate_time*40.0 ps;
  constant t_or2  : time := simulate_time*22.0 ps;
  constant t_or3  : time := simulate_time*26.6 ps;
  constant t_or4  : time := simulate_time*33.2 ps;
  constant t_or5  : time := simulate_time*40.0 ps;
  constant t_xor2 : time := simulate_time*24.0 ps;
  constant t_xor3 : time := simulate_time*29.0 ps;
  constant t_rej  : time := simulate_time*10.0 ps; -- rejeita pulsos estreitos
  constant t_FFD  : time := simulate_time*45.0 ps;
  constant t_FFT  : time := simulate_time*44.0 ps;

  subtype reg2  is bit_vector(1 downto 0);
  subtype reg3  is bit_vector(2 downto 0);
  subtype reg4  is bit_vector(3 downto 0);
  subtype reg5  is bit_vector(4 downto 0);
  subtype reg6  is bit_vector(5 downto 0);
  subtype reg8  is bit_vector(7 downto 0);
  subtype reg9  is bit_vector(8 downto 0);
  subtype reg10 is bit_vector(9 downto 0);
  subtype reg12 is bit_vector(11 downto 0);
  subtype reg13 is bit_vector(12 downto 0);
  subtype reg14 is bit_vector(13 downto 0);
  subtype reg15 is bit_vector(14 downto 0);
  subtype reg16 is bit_vector(15 downto 0);
  subtype reg17 is bit_vector(16 downto 0);
  subtype reg20 is bit_vector(19 downto 0);
  subtype reg24 is bit_vector(23 downto 0);
  subtype reg30 is bit_vector(29 downto 0);
  subtype reg31 is bit_vector(30 downto 0);
  subtype reg32 is bit_vector(31 downto 0);
  subtype reg33 is bit_vector(32 downto 0);
  subtype reg63 is bit_vector(62 downto 0);
  subtype reg64 is bit_vector(63 downto 0);
  subtype reg65 is bit_vector(64 downto 0);  

  function BIT2INT(i: bit) return integer;
  function B2STR(s: in bit) return string;
  function BV2STR(s: in bit_vector) return string;
  function BV32HEX(w: in bit_vector(31 downto 0)) return string;
  function rising_edge(signal s: bit) return boolean;
  function falling_edge(signal s: bit) return boolean;
  function log2_ceil(n: natural) return natural;

  function BV2INT(S: reg32) return integer;
  function INT2BV32(S: integer) return reg32;
  
  function INT2BV16(s: integer) return reg16;
  function BV2INT16(S: reg16) return integer;
  function BV2INT5(S: reg5) return integer;
  function BV2INT4(S: reg4) return integer;

  function SLV2BV32(s: std_logic_vector(31 downto 0)) return reg32;
  function BV2SLV32(s: reg32) return std_logic_vector;
  function SLV2BV8(s: std_logic_vector(7 downto 0)) return reg8;
  function BV2SLV8(s: reg8) return std_logic_vector;
  
end p_WIRES;

package body p_WIRES is

  -- ---------------------------------------------------------
  function rising_edge(signal S: bit)
    return boolean is
  begin
    if (S'event) and         -- ocorreu evento em S
       (S = '1') and         -- e o valor atual é '1'
       (S'last_value = '0')  -- e o valor anterior era '0'
    then
      return TRUE;
    else
      return FALSE;
    end if;
  end rising_edge;
  -- ---------------------------------------------------------
  function falling_edge(signal S: bit)
    return boolean is
  begin
    if (S'event) and         -- ocorreu evento em S
       (S = '0') and         -- e o valor atual é '0'
       (S'last_value = '1')  -- e o valor anterior era '1'
    then
      return TRUE;
    else
      return FALSE;
    end if;
  end falling_edge;

  -- ---------------------------------------------------------
  -- find minimum number of bits required to
  -- represent N as an unsigned binary number
  function log2_ceil(n: natural) return natural is
  begin
    if n < 2 then
      return 0;
    else
      return 1 + log2_ceil(n/2);
    end if;
  end log2_ceil;

  -- ---------------------------------------------------------
  -- convert bit to integer in {0,1}
  function BIT2INT(i: bit) return integer is
  begin
    if i = '1' then
      return 1;
    else
      return 0;
    end if;
  end BIT2INT;
    
  -- ---------------------------------------------------------
  function BV2INT(S: reg32) return integer is
    variable result: integer := 0; 
  begin
   if S(31) = '1' then result := -(1024*1024*2); else result := 0; end if;
    for i in S'range loop
      result := result * 2;
      if S(i) = '1' then
        result := result + 1;
      end if;
    end loop;
    return result;
  end BV2INT;

  -- ---------------------------------------------------------
  function INT2BV32(S: integer) return reg32 is
    variable result: reg32;
  begin
    result := SLV2BV32( std_logic_vector(to_signed(S,32)) );
    return result;
  end INT2BV32;

  -- ---------------------------------------------------------
  function BV2INT16(S: reg16) return integer is
    variable result: integer;
  begin
    if S(15) = '1' then result := -65536; else result := 0; end if;
    for i in S'range loop
      result := result * 2;
      if S(i) = '1' then
        result := result + 1;
      end if;
    end loop;
    return result;
  end BV2INT16;

  -- ---------------------------------------------------------
  function BV2INT5(S: reg5) return integer is
    variable result: integer := 0;
  begin
    if S(4) = '1' then result := 16; end if;
    if S(3) = '1' then result := result + 8; end if;
    if S(2) = '1' then result := result + 4; end if;
    if S(1) = '1' then result := result + 2; end if;
    if S(0) = '1' then result := result + 1; end if;
    return result;
  end BV2INT5;

  -- ---------------------------------------------------------
  function BV2INT4(S: reg4) return integer is
    variable result: integer := 0;
  begin
    if S(3) = '1' then result := 8; end if;
    if S(2) = '1' then result := result + 4; end if;
    if S(1) = '1' then result := result + 2; end if;
    if S(0) = '1' then result := result + 1; end if;
    return result;
  end BV2INT4;

  -- ---------------------------------------------------------
  function INT2BV16(s: integer) return reg16 is
    variable result: reg16;
    variable digit: integer := 2**15;
    variable local: integer;
  begin
    local := s;
    for i in 15 downto 0 loop
      if local/digit >= 1 then
        result(i) := '1';
        local := local - digit;
      else
        result(i) := '0';
      end if;
      digit := digit / 2;
    end loop;
    return result;
  end INT2BV16;
 
  -- ---------------------------------------------------------
  function BV2SLV32(s: reg32) return std_logic_vector is
    variable result: std_logic_vector(31 downto 0);
  begin
    for i in 31 downto 0 loop
      if s(i) = '1' then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
    end loop;
    return result;
  end BV2SLV32;
  
  -- ---------------------------------------------------------
  function SLV2BV32(s: std_logic_vector(31 downto 0)) return reg32 is
    variable result: reg32;
  begin
    for i in 31 downto 0 loop
      if s(i) = '1' then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
    end loop;
    return result;
  end SLV2BV32;
  
  -- ---------------------------------------------------------
  function BV2SLV8(s: reg8) return std_logic_vector is
    variable result: std_logic_vector(7 downto 0);
  begin
    for i in 7 downto 0 loop
      if s(i) = '1' then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
    end loop;
    return result;
  end BV2SLV8;
  
  -- ---------------------------------------------------------
  function SLV2BV8(s: std_logic_vector(7 downto 0)) return reg8 is
    variable result: reg8;
  begin
    for i in 7 downto 0 loop
      if s(i) = '1' then
        result(i) := '1';
      else
        result(i) := '0';
      end if;
    end loop;
    return result;
  end SLV2BV8;
  
  -- ---------------------------------------------------------
  function B2STR(s: in bit) return string is
    variable stmp : string(2 downto 1);
  begin
    if s = '1' then
      stmp(1) := '1';
    elsif s = '0' then
      stmp(1) := '0';
    else
      stmp(1) := 'x';
    end if;
    return stmp;
  end;
  -- ---------------------------------------------------------
  function BV2STR(s: in bit_vector) return string is
    variable stmp : string(s'left+1 downto 1);
  begin
    for i  in s'reverse_range loop
      if s(i) = '1' then
        stmp(i+1) := '1';
      elsif s(i) = '0' then
        stmp(i+1) := '0';
      else
        stmp(i+1) := 'x';
      end if;
    end loop;  -- i
    return stmp;
  end;
  -- ---------------------------------------------------------

  -- convert bit_vector(32) to an hexadecimal string
  function BV32HEX(w: in bit_vector(31 downto 0)) return string is
    variable nibble: reg4;
    variable stmp : string(8 downto 1);
  begin
    for i in 8 downto 1 loop
      nibble := w(((i-1)*4+3) downto ((i-1)*4));
      case nibble is
        when b"0000" => stmp(i) := '0';
        when b"0001" => stmp(i) := '1';                        
        when b"0010" => stmp(i) := '2';
        when b"0011" => stmp(i) := '3';                        
        when b"0100" => stmp(i) := '4';
        when b"0101" => stmp(i) := '5';                        
        when b"0110" => stmp(i) := '6';
        when b"0111" => stmp(i) := '7';                        
        when b"1000" => stmp(i) := '8';
        when b"1001" => stmp(i) := '9';                        
        when b"1010" => stmp(i) := 'a';
        when b"1011" => stmp(i) := 'b';                        
        when b"1100" => stmp(i) := 'c';
        when b"1101" => stmp(i) := 'd';                        
        when b"1110" => stmp(i) := 'e';
        when b"1111" => stmp(i) := 'f';                        
        when others  => stmp(i) := 'x';
      end case;
    end loop;
    return stmp;
  end BV32HEX;
  -- ---------------------------------------------------------

end p_WIRES;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
