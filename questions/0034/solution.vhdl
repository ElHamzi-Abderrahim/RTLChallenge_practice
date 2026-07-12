library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gray_counter is
  generic (
    WIDTH : integer := 4
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    gray_count : out std_logic_vector(WIDTH-1 downto 0);
    binary_count : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity gray_counter;

architecture rtl of gray_counter is
  signal binary_counter : unsigned(WIDTH-1 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        binary_counter <= (others => '0');
      elsif enable = '1' then
        binary_counter <= binary_counter + 1;
      end if;
    end if;
  end process;

  gray_count   <= std_logic_vector(binary_counter xor ('0' & binary_counter(WIDTH-1 downto 1)));
  binary_count <= std_logic_vector(binary_counter);
end architecture rtl;
