-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 07out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- display: exibe inteiro na saida padrao do simulador
--          NAO ALTERE ESTE MODELO
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use std.textio.all;
use work.p_wires.all;

entity display is
  port (rst,clk : in bit;
        enable  : in bit;
        data    : in reg32);
end display;

architecture functional of display is
  file output : text open write_mode is "STD_OUTPUT";
begin  -- functional

  U_WRITE_OUT: process(clk)
    variable msg : line;
  begin
    if falling_edge(clk) and enable = '1' then
      write ( msg, string'(BV32HEX(data)) );
      writeline( output, msg );
    end if;
  end process U_WRITE_OUT;

end functional;
-- ++ display ++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- MICO X
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity mico is
  port (rst,clk : in    bit);
end mico;

architecture functional of mico is

  component display is                  -- neste arquivo
    port (rst,clk : in bit;
          enable  : in bit;
          data    : in reg32);
  end component display;

  component mem_prog is                 -- no arquivo mem.vhd
    port (ender : in  reg6;
          instr : out reg32);
  end component mem_prog;

  component ULA is                      -- neste arquivo
    port (fun : in reg4;
          alfa,beta : in  reg32;
          gama      : out reg32);
  end component ULA;
 
  component R is                        -- neste arquivo
    port (clk         : in  bit;
          wr_en       : in  bit;
          r_a,r_b,r_c : in  reg4;
          A,B         : out reg32;
          C           : in  reg32);
  end component R;

  type t_control_type is record
    extZero  : bit;       -- estende com zero=1, com sinal=0
    selBeta  : bit;       -- seleciona fonte para entrada B da ULA
    wr_display: bit;      -- atualiza display=1
    selNxtIP : bit;       -- seleciona fonte do incremento do IP
    wr_reg   : bit;       -- atualiza registrador: R(c) <= C
  end record;

  type t_control_mem is array (0 to 15) of t_control_type;

  -- preencha esta tabela com os sinais de controle adequados
  -- a tabela eh indexada com o opcode da instrucao
  constant ctrl_table : t_control_mem := (
  --extZ sBeta wrD sIP wrR
    ('0','0', '0', '0','0'),            -- NOP
    ('0','0', '0', '0','1'),            -- ADD
    ('0','0', '0', '0','1'),            -- SUB
    ('0','0', '0', '0','1'),            -- MUL
    ('0','0', '0', '0','1'),            -- AND
    ('0','0', '0', '0','1'),            -- OR
    ('0','0', '0', '0','1'),            -- XOR
    ('0','0', '0', '0','1'),            -- NOT
    ('1','0', '0', '0','1'),            -- SLL
    ('1','0', '0', '0','1'),            -- SRL
    ('0','1', '0', '0','1'),            -- ORI
    ('0','1', '0', '0','1'),            -- ADDI
    ('0','0', '1', '0','0'),            -- SHOW
    ('0','0', '0', '1','0'),            -- JUMP
    ('0','0', '0', '1','0'),            -- BRANCH
    ('0','0', '0', '1','0'));           -- HALT

  signal extZero, selBeta, wr_display, selNxtIP, wr_reg : bit;

  signal instr, A, B, C, beta, extended : reg32;
  signal this  : t_control_type;
  signal const, ip : reg16;
  signal opcode : reg4;
  signal i_opcode : natural range 0 to 15;
  
begin  -- functional

  -- memoria de programa contem somente 64 palavras
  U_mem_prog: mem_prog port map(ip(5 downto 0), instr);

  opcode <= instr(31 downto 28);
  i_opcode <= BV2INT4(opcode);          -- indice do vetor DEVE ser inteiro
  
  this <= ctrl_table(i_opcode);         -- sinais de controle

  extZero    <= this.extZero;
  selBeta    <= this.selBeta;
  wr_display <= this.wr_display;
  selNxtIP   <= this.selNxtIP;
  wr_reg     <= this.wr_reg;

  
  
  U_regs: R port map (clk,A,B,C,r_a,r_b,r_c,wr_en);

  
  
  U_ULA: ULA port map (alfa,beta,gama,fun);

  
  -- nao altere esta linha
  U_display: display port map (rst, clk, wr_display, A);
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all; -- talvez não precise fazer duas vezes
use work.p_wires.all;

entity ULA is
  port (fun : in reg4;
        alfa,beta : in  reg32;
        gama      : out reg32);
end ULA;

architecture behaviour of ULA is

  -- signal
  signal result : STD_LOGIC_VECTOR(31 downto 0);
   signal X_temp, Y_temp : STD_LOGIC_VECTOR(31 downto 0);

begin

	X(31 downto 0) <= '0' & alfa(31 downto 0);
	Y(31 downto 0) <= '0' & beta(31 downto 0);

	ula_output <= result(31 downto 0);
	
	result <= 	(X(31 downto 0) + Y(31 downto 0)) when fun = "0001" else 		        --	ADD
					(X(31 downto 0) AND Y(31 downto 0)) when fun = "0100" else      --	AND
					(X(31 downto 0) OR Y(31 downto 0)) when fun = "0101" else 	--	OR
					('0' & not(X(31 downto 0)))  when fun = "0111" else		--	NOT
					'0' & Y when fun = "0000" else  				--	LDA
					("00" & X(31 downto 1)) when fun = "1001" else   		--	SHR
					('0' & X(31 downto 0) & '0') when fun = "1000" else		--	SHL
					(X(31 downto 0) * Y(31 downto 0)) when fun = "0011" else 	--	MUL
					"000000000";
  
  
  
end behaviour;
-- -----------------------------------------------------------------------



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity R is
  port (clk         : in  bit;
        wr_en       : in  bit;          -- ativo em 1
        r_a,r_b,r_c : in  reg4;
        A,B         : out reg32;
        C           : in  reg32);
end R;

architecture rtl of R is

  -- signal

begin






  
end rtl;
-- -----------------------------------------------------------------------
