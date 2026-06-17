library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift_register is
  port (
    clk : in std_logic;
    reset : in std_logic;
    x_i : in std_logic;
    sr_o : out std_logic_vector(3 downto 0)
  );
end entity shift_register;

architecture rtl of shift_register is
begin
  -- Your implementation here

end architecture rtl;
