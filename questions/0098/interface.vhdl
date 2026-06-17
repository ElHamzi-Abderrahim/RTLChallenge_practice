library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_unit is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    clear : in std_logic;
    in_valid : in std_logic;
    in_a : in signed(DATA_WIDTH-1 downto 0);
    in_b : in signed(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_acc : out signed(DATA_WIDTH*2+7 downto 0)
  );
end entity mac_unit;

architecture rtl of mac_unit is
begin
  -- Your implementation here

end architecture rtl;
