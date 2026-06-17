library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity eth_header_parser is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(7 downto 0);
    in_sof : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_dst_mac : out std_logic_vector(47 downto 0);
    out_src_mac : out std_logic_vector(47 downto 0);
    out_ethertype : out std_logic_vector(15 downto 0)
  );
end entity eth_header_parser;

architecture rtl of eth_header_parser is
begin
  -- Your implementation here

end architecture rtl;
