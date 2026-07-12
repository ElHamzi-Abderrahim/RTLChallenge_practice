library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity johnson_counter is
  generic (
    WIDTH : integer := 4
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    count_out : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity johnson_counter;

architecture rtl of johnson_counter is
  signal counter : std_logic_vector(WIDTH-1 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= (others => '0');
      elsif enable = '1' then
        counter <= counter(WIDTH-2 downto 0) & (not counter(WIDTH-1));
      end if;
    end if;
  end process;

  count_out <= counter;
end architecture rtl;
