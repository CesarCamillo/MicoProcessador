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
    x"00000000", -- nop

    x"b00f000a", -- insere o valor de n no registrador 15
    x"b00e0001", -- insere o multiplicador no registrador 14
    x"00000000", -- nop
    
    x"b0010001", -- inicializa o registrador com o valor do fatorial
    x"00000000", -- nop
      
    x"efe0003c", -- branch, se o valor no registrador de e for igual a f,
                 -- imprime o fatorial e para tudo
    x"00000000", -- nop

    
    x"31e10000", -- multiplica o registrador com o valor pelo multiplicador e guarda
                 -- no registrador do valor
    x"00000000", -- nop
    
    x"be0e0001", -- aumenta 1 no multiplicador
    x"00000000", -- nop
    
    x"d0000006", -- faz o jump para o branch
    

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
    x"31e10000", -- multiplicação final pra achar o fatorial de N
    x"ce000000", -- imprime o valor de N
    x"c1000000", -- imprime o valor do fatorial de N
    x"f000003f"); -- encerra o programa

  function BV2INT6(S: reg6) return integer is
    variable result: integer;
  begin
    -- if S(5) = '1' then result := -63; else result := 0; end if;
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
