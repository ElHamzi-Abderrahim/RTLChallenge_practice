library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_interface is
  port (
    clk : in std_logic;
    reset : in std_logic;
    req_i : in std_logic;
    req_rnw_i : in std_logic;
    req_addr_i : in std_logic_vector(3 downto 0);
    req_wdata_i : in std_logic_vector(31 downto 0);
    req_ready_o : out std_logic;
    req_rdata_o : out std_logic_vector(31 downto 0)
  );
end entity mem_interface;

architecture rtl of mem_interface is
begin
  -- Your implementation here

end architecture rtl;
