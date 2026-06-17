library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity async_fifo is
  generic (
    DATA_WIDTH : integer := 8;
    FIFO_DEPTH : integer := 16
  );
  port (
    wr_clk : in std_logic;
    wr_rst_n : in std_logic;
    wr_en : in std_logic;
    wr_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    wr_full : out std_logic;
    rd_clk : in std_logic;
    rd_rst_n : in std_logic;
    rd_en : in std_logic;
    rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    rd_empty : out std_logic
  );
end entity async_fifo;

architecture rtl of async_fifo is
begin
  -- Your implementation here

end architecture rtl;
