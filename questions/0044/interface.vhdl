library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity thermometer_to_binary is
  generic (
    THERMO_WIDTH : integer := 7;
    BINARY_WIDTH : integer := 3
  );
  port (
    thermo_in : in std_logic_vector(THERMO_WIDTH-1 downto 0);
    binary_out : out std_logic_vector(BINARY_WIDTH-1 downto 0);
    valid : out std_logic
  );
end entity thermometer_to_binary;

architecture rtl of thermometer_to_binary is
begin
  -- Your implementation here

end architecture rtl;
