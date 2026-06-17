library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity population_counter is
  generic (
    INPUT_WIDTH : integer := 8;
    COUNT_WIDTH : integer := 4
  );
  port (
    data_in : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    count_out : out std_logic_vector(COUNT_WIDTH-1 downto 0)
  );
end entity population_counter;

architecture rtl of population_counter is
begin
  -- Your implementation here

end architecture rtl;
