-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 07out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

use work.p_wires.all;

entity mem_prog is
  port (ender : in  reg6;
        instr : out reg32);

  type t_prog_mem is array (0 to 63) of reg32;

  -- memoria de programa contem somente 64 palavras
  constant program : t_prog_mem := (
    x"c0000000",
    x"b0010001",
    x"c1110000",
    x"11120000",
    x"c2000000",
    x"c0000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"a0011111",
    x"c1000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"f0000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000");


  function BV2INT6(S: reg6) return integer is
    variable result: integer;
  begin
    for i in S'range loop
      result := result * 2;
      if S(i) = '1' then
        result := result + 1;
      end if;
    end loop;
    return result;
  end BV2INT6;
  
end mem_prog;

-- nao altere esta arquitetura
architecture tabela of mem_prog is
begin  -- tabela

  instr <= program( BV2INT6(ender) );

end tabela;
