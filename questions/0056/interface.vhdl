library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter_manager is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    cmd_valid : in std_logic;
    cmd_op : in std_logic_vector(1 downto 0);
    cmd_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    cmd_wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
    cmd_ready : out std_logic;
    resp_valid : out std_logic;
    resp_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity counter_manager;

architecture rtl of counter_manager is
begin
  -- Your implementation here

end architecture rtl;
