library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity binary_to_bcd is
  generic (
    BINARY_WIDTH : integer := 8;
    BCD_DIGITS : integer := 3;
    BCD_WIDTH : integer := 12
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    start : in std_logic;
    binary_in : in std_logic_vector(BINARY_WIDTH-1 downto 0);
    bcd_out : out std_logic_vector(BCD_WIDTH-1 downto 0);
    valid : out std_logic
  );
end entity binary_to_bcd;

architecture rtl of binary_to_bcd is
begin
  -- Your implementation here

end architecture rtl;
