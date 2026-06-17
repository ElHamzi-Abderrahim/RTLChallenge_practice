library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_read_ctrl is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    num_reads : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    done : out std_logic;
    checksum : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity mem_read_ctrl;

architecture rtl of mem_read_ctrl is
begin
  -- Your implementation here

end architecture rtl;
