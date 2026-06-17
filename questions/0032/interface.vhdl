library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_divider is
  generic (
    DIVIDE_FACTOR : integer := 2
  );
  port (
    clk_in : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    clk_out : out std_logic
  );
end entity clock_divider;

architecture rtl of clock_divider is
begin
  -- Your implementation here

end architecture rtl;
