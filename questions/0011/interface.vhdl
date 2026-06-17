library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity odd_counter is
  port (
    clk : in std_logic;
    reset : in std_logic;
    cnt_o : out std_logic_vector(7 downto 0)
  );
end entity odd_counter;

architecture rtl of odd_counter is
begin
  -- Your implementation here

end architecture rtl;
