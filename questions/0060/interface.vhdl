library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity regfile_max is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    count : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    write_en : in std_logic;
    write_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    busy : out std_logic;
    done : out std_logic;
    max_val : out std_logic_vector(DATA_WIDTH-1 downto 0);
    max_idx : out std_logic_vector(ADDR_WIDTH-1 downto 0)
  );
end entity regfile_max;

architecture rtl of regfile_max is
begin
  -- Your implementation here

end architecture rtl;
