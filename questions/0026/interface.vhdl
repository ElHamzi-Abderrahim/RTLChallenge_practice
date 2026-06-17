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
begin
  -- Your implementation here

end architecture rtl;
