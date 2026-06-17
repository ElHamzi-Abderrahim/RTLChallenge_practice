library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fir_filter is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_in : in signed(DATA_WIDTH-1 downto 0);
    data_out : out signed(DATA_WIDTH+1 downto 0)
  );
end entity fir_filter;

architecture rtl of fir_filter is
begin
  -- Your implementation here

end architecture rtl;
