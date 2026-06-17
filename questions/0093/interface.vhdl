library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ipv4_checksum is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(15 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_checksum : out std_logic_vector(15 downto 0);
    out_valid_hdr : out std_logic
  );
end entity ipv4_checksum;

architecture rtl of ipv4_checksum is
begin
  -- Your implementation here

end architecture rtl;
