library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lut_interpolator is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8;
    FRAC_BITS : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    phase : in std_logic_vector(ADDR_WIDTH+FRAC_BITS-1 downto 0);
    done : out std_logic;
    result : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity lut_interpolator;

architecture rtl of lut_interpolator is
begin
  -- Your implementation here

end architecture rtl;
