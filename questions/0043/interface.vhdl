library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity leading_zero_counter is
  generic (
    INPUT_WIDTH : integer := 8;
    COUNT_WIDTH : integer := 4
  );
  port (
    data_in : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    zero_count : out std_logic_vector(COUNT_WIDTH-1 downto 0);
    all_zero : out std_logic
  );
end entity leading_zero_counter;

architecture rtl of leading_zero_counter is
begin
  -- Your implementation here

end architecture rtl;
