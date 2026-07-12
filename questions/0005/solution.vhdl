library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sequence_detector is
  generic (
    PATTERN : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    data_in : in std_logic;
    pattern_detected : out std_logic
  );
end entity sequence_detector;

architecture rtl of sequence_detector is
  signal shift_reg : std_logic_vector(PATTERN-1 downto 0);
begin
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      shift_reg <= (others => '0');
    elsif rising_edge(clk) then
      shift_reg <= shift_reg(PATTERN-2 downto 0) & data_in;
    end if;
  end process;

  pattern_detected <= '1' when unsigned(shift_reg) = to_unsigned(PATTERN, PATTERN)
                          else '0';
end architecture rtl;
