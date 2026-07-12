library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serial_in_parallel_out is
  port (
    clock : in std_logic;
    reset : in std_logic;
    serial_in : in std_logic;
    parallel_out : out std_logic_vector(7 downto 0)
  );
end entity serial_in_parallel_out;

architecture rtl of serial_in_parallel_out is
  signal shift_reg : std_logic_vector(7 downto 0);
begin
  process(clock)
  begin
    if rising_edge(clock) then
      if reset = '1' then
        shift_reg <= (others => '0');
      else
        shift_reg <= shift_reg(6 downto 0) & serial_in;
      end if;
    end if;
  end process;

  parallel_out <= shift_reg;
end architecture rtl;
