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
begin
  -- Your implementation here

end architecture rtl;
