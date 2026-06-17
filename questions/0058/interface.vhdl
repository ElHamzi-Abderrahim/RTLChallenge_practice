library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_copy_ctrl is
  generic (
    ADDR_WIDTH : integer := 8;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    src_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    dst_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    length : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    busy : out std_logic;
    done : out std_logic
  );
end entity mem_copy_ctrl;

architecture rtl of mem_copy_ctrl is
begin
  -- Your implementation here

end architecture rtl;
