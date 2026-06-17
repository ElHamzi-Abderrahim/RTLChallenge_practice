library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplier is
  generic (
    INPUT_WIDTH : integer := 8
  );
  port (
    data_in_1 : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    data_in_2 : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    data_out : out std_logic_vector(2*INPUT_WIDTH-1 downto 0)
  );
end entity multiplier;

architecture rtl of multiplier is
begin
  -- Your implementation here

end architecture rtl;
