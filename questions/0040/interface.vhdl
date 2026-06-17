library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity crc_calculator is
  generic (
    CRC_WIDTH : integer := 8;
    POLYNOMIAL : integer := 8
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_valid : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    start : in std_logic;
    crc_out : out std_logic_vector(CRC_WIDTH-1 downto 0);
    crc_valid : out std_logic
  );
end entity crc_calculator;

architecture rtl of crc_calculator is
begin
  -- Your implementation here

end architecture rtl;
