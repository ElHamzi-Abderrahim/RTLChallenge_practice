library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity parallel_to_serial is
  port (
    clk : in std_logic;
    reset : in std_logic;
    empty_o : out std_logic;
    parallel_i : in std_logic_vector(3 downto 0);
    serial_o : out std_logic;
    valid_o : out std_logic
  );
end entity parallel_to_serial;

architecture rtl of parallel_to_serial is
  signal shift_reg : std_logic_vector(3 downto 0);
  signal bit_count : unsigned(2 downto 0);
  signal busy      : std_logic;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      shift_reg <= (others => '0');
      bit_count <= (others => '0');
      busy      <= '0';
    elsif rising_edge(clk) then
      if busy = '0' then
        shift_reg <= parallel_i;
        bit_count <= (others => '0');
        busy      <= '1';
      else
        shift_reg <= '0' & shift_reg(3 downto 1);
        bit_count <= bit_count + 1;
        if bit_count = 3 then
          busy <= '0';
        end if;
      end if;
    end if;
  end process;

  empty_o  <= not busy;
  valid_o  <= busy;
  serial_o <= shift_reg(0);
end architecture rtl;
