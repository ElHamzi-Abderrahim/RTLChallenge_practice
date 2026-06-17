library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity diff_calc is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_diff : out signed(DATA_WIDTH downto 0)
  );
end entity diff_calc;

architecture rtl of diff_calc is
begin
  -- Your implementation here

end architecture rtl;
