library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity scratchpad_acc is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    src_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    count : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    dst_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    busy : out std_logic;
    done : out std_logic;
    result : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity scratchpad_acc;

architecture rtl of scratchpad_acc is
begin
  -- Your implementation here

end architecture rtl;
