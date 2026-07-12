library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ring_counter is
  generic (
    COUNTER_WIDTH : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    count_out : out std_logic_vector(COUNTER_WIDTH-1 downto 0)
  );
end entity ring_counter;

architecture rtl of ring_counter is
  signal count_reg : std_logic_vector(COUNTER_WIDTH-1 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        count_reg <= std_logic_vector(to_unsigned(1, COUNTER_WIDTH));
      else
        count_reg <= count_reg(COUNTER_WIDTH-2 downto 0) & count_reg(COUNTER_WIDTH-1);
      end if;
    end if;
  end process;

  count_out <= count_reg;
end architecture rtl;
