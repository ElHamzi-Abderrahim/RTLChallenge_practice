library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_filter is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    cfg_mac : in std_logic_vector(47 downto 0);
    cfg_promisc : in std_logic;
    in_valid : in std_logic;
    in_dst_mac : in std_logic_vector(47 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_accept : out std_logic;
    out_reason : out std_logic_vector(2 downto 0)
  );
end entity mac_filter;

architecture rtl of mac_filter is
begin
  -- Your implementation here

end architecture rtl;
