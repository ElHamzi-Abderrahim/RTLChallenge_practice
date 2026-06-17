library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity conv_1d is
  generic (
    DATA_WIDTH : integer := 8;
    KERNEL_SIZE : integer := 3
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    kernel_valid : in std_logic;
    kernel_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    kernel_ready : out std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH*2+$clog2(KERNEL_SIZE)-1 downto 0);
    out_last : out std_logic
  );
end entity conv_1d;

architecture rtl of conv_1d is
begin
  -- Your implementation here

end architecture rtl;
