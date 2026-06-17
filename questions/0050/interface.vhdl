library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decimation_filter is
  generic (
    DATA_WIDTH : integer := 8;
    DECIMATION_FACTOR : integer := 4
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_in : in signed(DATA_WIDTH-1 downto 0);
    data_valid_in : in std_logic;
    data_out : out signed(DATA_WIDTH-1 downto 0);
    data_valid_out : out std_logic
  );
end entity decimation_filter;

architecture rtl of decimation_filter is
begin
  -- Your implementation here

end architecture rtl;
