library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity histogram_calc is
  generic (
    BIN_ADDR_WIDTH : integer := 4;
    COUNT_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    clear : in std_logic;
    data_valid : in std_logic;
    data_in : in std_logic_vector(BIN_ADDR_WIDTH-1 downto 0);
    read_req : in std_logic;
    read_addr : in std_logic_vector(BIN_ADDR_WIDTH-1 downto 0);
    ready : out std_logic;
    read_valid : out std_logic;
    read_data : out std_logic_vector(COUNT_WIDTH-1 downto 0)
  );
end entity histogram_calc;

architecture rtl of histogram_calc is
begin
  -- Your implementation here

end architecture rtl;
