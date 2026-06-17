library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lfsr is
  port (
    clk : in std_logic;
    reset : in std_logic;
    lfsr_o : out std_logic_vector(3 downto 0)
  );
end entity lfsr;

architecture rtl of lfsr is
begin
  -- Your implementation here

end architecture rtl;
