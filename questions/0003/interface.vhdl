library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ring_counter is
  generic (
    COUNTER_WIDTH : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    count_out : out std_logic_vector(COUNTER_WIDTH-1 downto 0)
  );
end entity ring_counter;

architecture rtl of ring_counter is
begin
  -- Your implementation here

end architecture rtl;
