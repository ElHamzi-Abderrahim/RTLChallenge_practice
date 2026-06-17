library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity running_sum is
  generic (
    DATA_WIDTH : integer := 16
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
    out_sum : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity running_sum;

architecture rtl of running_sum is
begin
  -- Your implementation here

end architecture rtl;
