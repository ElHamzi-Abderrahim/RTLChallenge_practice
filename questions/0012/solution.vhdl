library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift_register is
  port (
    clk : in std_logic;
    reset : in std_logic;
    x_i : in std_logic;
    sr_o : out std_logic_vector(3 downto 0)
  );
end entity shift_register;

architecture rtl of shift_register is
  signal shift_reg : std_logic_vector(3 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      shift_reg <= (others => '0');
    elsif rising_edge(clk) then
      shift_reg <= shift_reg(2 downto 0) & x_i;
    end if;
  end process;

  sr_o <= shift_reg;
end architecture rtl;
