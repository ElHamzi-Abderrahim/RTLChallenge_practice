library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity debounce is
  generic (
    CLK_FREQ : integer := 50000000;
    DEBOUNCE_TIME_MS : integer := 20
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    button_in : in std_logic;
    button_out : out std_logic
  );
end entity debounce;

architecture rtl of debounce is
begin
  -- Your implementation here

end architecture rtl;
