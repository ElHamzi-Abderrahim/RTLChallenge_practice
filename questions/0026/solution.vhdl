library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity seven_segment_driver is
  generic (
    ACTIVE_HIGH : integer := 1
  );
  port (
    bcd_digit : in std_logic_vector(3 downto 0);
    enable : in std_logic;
    segments : out std_logic_vector(6 downto 0);
    digit_valid : out std_logic
  );
end entity seven_segment_driver;

architecture rtl of seven_segment_driver is
  signal seg_pattern : std_logic_vector(6 downto 0);
  signal valid       : std_logic;
begin
  process(bcd_digit)
  begin
    valid <= '1';
    case bcd_digit is
      when "0000" => seg_pattern <= "0111111";
      when "0001" => seg_pattern <= "0000110";
      when "0010" => seg_pattern <= "1011011";
      when "0011" => seg_pattern <= "1001111";
      when "0100" => seg_pattern <= "1100110";
      when "0101" => seg_pattern <= "1101101";
      when "0110" => seg_pattern <= "1111101";
      when "0111" => seg_pattern <= "0000111";
      when "1000" => seg_pattern <= "1111111";
      when "1001" => seg_pattern <= "1101111";
      when others =>
        seg_pattern <= "0000000";
        valid <= '0';
    end case;
  end process;

  segments <= seg_pattern       when (enable = '1' and ACTIVE_HIGH /= 0) else
              (not seg_pattern) when (enable = '1' and ACTIVE_HIGH = 0)  else
              "0000000"         when (ACTIVE_HIGH /= 0)                   else
              "1111111";

  digit_valid <= valid when enable = '1' else '0';
end architecture rtl;
