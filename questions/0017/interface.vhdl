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
begin
  -- Your implementation here

end architecture rtl;
