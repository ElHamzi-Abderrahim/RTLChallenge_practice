library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_arbiter is
  generic (
    NUM_MASTERS : integer := 4;
    ADDR_WIDTH : integer := 8;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    req : in std_logic_vector(NUM_MASTERS-1 downto 0);
    req_wr : in std_logic_vector(NUM_MASTERS-1 downto 0);
    req_addr : in std_logic_vector(NUM_MASTERS*ADDR_WIDTH-1 downto 0);
    req_wdata : in std_logic_vector(NUM_MASTERS*DATA_WIDTH-1 downto 0);
    gnt : out std_logic_vector(NUM_MASTERS-1 downto 0);
    gnt_rdata : out std_logic_vector(NUM_MASTERS*DATA_WIDTH-1 downto 0);
    gnt_rvalid : out std_logic_vector(NUM_MASTERS-1 downto 0)
  );
end entity mem_arbiter;

architecture rtl of mem_arbiter is
begin
  -- Your implementation here

end architecture rtl;
