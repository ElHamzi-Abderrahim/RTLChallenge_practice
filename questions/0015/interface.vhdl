library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity binary_to_gray_code is
  generic (
    VEC_W : integer := 4
  );
  port (
    bin_i : in std_logic_vector(VEC_W-1 downto 0);
    gray_o : out std_logic_vector(VEC_W-1 downto 0)
  );
end entity binary_to_gray_code;

architecture rtl of binary_to_gray_code is
begin
  -- Your implementation here

end architecture rtl;
