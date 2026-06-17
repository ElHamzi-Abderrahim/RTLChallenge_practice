library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arp_detector is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(7 downto 0);
    in_sof : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_is_request : out std_logic;
    out_sender_ip : out std_logic_vector(31 downto 0);
    out_target_ip : out std_logic_vector(31 downto 0)
  );
end entity arp_detector;

architecture rtl of arp_detector is
begin
  -- Your implementation here

end architecture rtl;
