library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity relu_unit is
  generic (
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_data : in signed(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out signed(DATA_WIDTH-1 downto 0)
  );
end entity relu_unit;

architecture rtl of relu_unit is
begin
  -- Your implementation here

end architecture rtl;
