library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bubble_sort is
  generic (
    DATA_WIDTH : integer := 8;
    MAX_SIZE : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_last : out std_logic
  );
end entity bubble_sort;

architecture rtl of bubble_sort is
begin
  -- Your implementation here

end architecture rtl;
