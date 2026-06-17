library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity edge_detector is
  port (
    clk : in std_logic;
    reset : in std_logic;
    a_i : in std_logic;
    rising_edge_o : out std_logic;
    falling_edge_o : out std_logic
  );
end entity edge_detector;

architecture rtl of edge_detector is
begin
  -- Your implementation here

end architecture rtl;
