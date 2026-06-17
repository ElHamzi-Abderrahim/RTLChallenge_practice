library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gray_to_binary is
  generic (
    WIDTH : integer := 4
  );
  port (
    gray_in : in std_logic_vector(WIDTH-1 downto 0);
    binary_out : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity gray_to_binary;

architecture rtl of gray_to_binary is
begin
  -- Your implementation here

end architecture rtl;
