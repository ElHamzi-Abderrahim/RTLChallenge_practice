library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity binary_to_one_hot is
  generic (
    BIN_W : integer := 4;
    ONE_HOT_W : integer := 16
  );
  port (
    bin_i : in std_logic_vector(BIN_W-1 downto 0);
    one_hot_o : out std_logic_vector(ONE_HOT_W-1 downto 0)
  );
end entity binary_to_one_hot;

architecture rtl of binary_to_one_hot is
begin
  -- Your implementation here

end architecture rtl;
