-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 26out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- testbench para Mico X
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity tb_mico is
end tb_mico;

architecture TB of tb_mico is

  component mico is
    port (rst,clk : in    bit);
  end component mico;

  signal clk,rst : bit;
  
begin  -- TB

  U_mico: mico port map (rst,clk);

  U_clock: process
  begin
    clk <= '1';      -- executa e
    wait for t_clock_period / 2;  -- espera meio ciclo
    clk <= '0';      -- volta a executar e
    wait for t_clock_period / 2;  -- espera meio ciclo e volta ao topo
  end process;

  U_reset: process
  begin
    rst <= '1';      -- executa e
    wait for t_clock_period * 0.25;  -- espera por 1/4 de ciclo
    rst <= '0';      -- volta a executar e
    wait;            -- espera para sempre
  end process;
  
end TB;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


----------------------------------------------------------------
configuration CFG_TB of tb_mico is
	for TB
        end for;
end CFG_TB;
----------------------------------------------------------------
