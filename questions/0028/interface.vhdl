library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serial_in_parallel_out is
  port (
    clock : in std_logic;
    reset : in std_logic;
    serial_in : in std_logic;
    parallel_out : out std_logic_vector(7 downto 0)
  );
end entity serial_in_parallel_out;

architecture rtl of serial_in_parallel_out is
begin
  -- Your implementation here

end architecture rtl;
