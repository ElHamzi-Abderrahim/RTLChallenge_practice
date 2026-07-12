library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity moving_average is
  generic (
    DATA_WIDTH : integer := 8;
    WINDOW_SIZE : integer := 4
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity moving_average;

architecture rtl of moving_average is
  type win_t is array(0 to WINDOW_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal window  : win_t;
  signal sum_reg : unsigned(DATA_WIDTH+7 downto 0);
begin
  process(clk, reset)
    variable i : integer;
  begin
    if reset = '1' then
      i := 0;
      while i < WINDOW_SIZE loop
        window(i) <= (others => '0');
        i := i + 1;
      end loop;
      sum_reg <= (others => '0');
    elsif rising_edge(clk) then
      sum_reg <= sum_reg
                 + resize(unsigned(data_in), DATA_WIDTH+8)
                 - resize(unsigned(window(WINDOW_SIZE-1)), DATA_WIDTH+8);
      i := WINDOW_SIZE-1;
      while i > 0 loop
        window(i) <= window(i-1);
        i := i - 1;
      end loop;
      window(0) <= data_in;
    end if;
  end process;

  data_out <= std_logic_vector(resize(sum_reg / WINDOW_SIZE, DATA_WIDTH));
end architecture rtl;
