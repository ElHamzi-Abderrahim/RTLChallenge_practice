library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity max_pool is
  generic (
    DATA_WIDTH : integer := 8;
    POOL_SIZE : integer := 4
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
    out_max : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity max_pool;

architecture rtl of max_pool is
begin
  -- Your implementation here

end architecture rtl;
