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
begin
  -- Your implementation here

end architecture rtl;
