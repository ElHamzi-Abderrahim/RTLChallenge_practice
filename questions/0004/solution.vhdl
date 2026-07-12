library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ripple_counter is
  generic (
    COUNTER_WIDTH : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    count_out : out std_logic_vector(COUNTER_WIDTH-1 downto 0)
  );
end entity ripple_counter;

architecture rtl of ripple_counter is
  signal count_reg : unsigned(COUNTER_WIDTH-1 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        count_reg <= (others => '0');
      else
        count_reg <= count_reg + 1;
      end if;
    end if;
  end process;

  count_out <= std_logic_vector(count_reg);
end architecture rtl;
