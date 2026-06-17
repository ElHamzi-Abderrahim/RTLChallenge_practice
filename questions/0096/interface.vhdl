library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vlan_detector is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_ethertype : in std_logic_vector(15 downto 0);
    in_tci : in std_logic_vector(15 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_is_tagged : out std_logic;
    out_pcp : out std_logic_vector(2 downto 0);
    out_dei : out std_logic;
    out_vid : out std_logic_vector(11 downto 0)
  );
end entity vlan_detector;

architecture rtl of vlan_detector is
begin
  -- Your implementation here

end architecture rtl;
