library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lfsr is
  port (
    clk : in std_logic;
    reset : in std_logic;
    lfsr_o : out std_logic_vector(3 downto 0)
  );
end entity lfsr;

architecture rtl of lfsr is
  signal lfsr_reg : std_logic_vector(3 downto 0);
  signal feedback : std_logic;
begin
  feedback <= lfsr_reg(3) xor lfsr_reg(1);

  process(clk, reset)
  begin
    if reset = '1' then
      lfsr_reg <= x"E";
    elsif rising_edge(clk) then
      lfsr_reg <= lfsr_reg(2 downto 0) & feedback;
    end if;
  end process;

  lfsr_o <= lfsr_reg;
end architecture rtl;
