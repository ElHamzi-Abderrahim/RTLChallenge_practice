library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is
  generic (
    INPUT_WIDTH : integer := 8
  );
  port (
    data_in_1 : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    data_in_2 : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    data_out : out std_logic_vector(INPUT_WIDTH downto 0)
  );
end entity adder;

architecture rtl of adder is
begin
  -- Your implementation here

end architecture rtl;
