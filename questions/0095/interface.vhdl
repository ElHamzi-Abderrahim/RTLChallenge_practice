library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pkt_len_validator is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(7 downto 0);
    in_last : in std_logic;
    hdr_total_len : in std_logic_vector(15 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_len_ok : out std_logic;
    out_actual_len : out std_logic_vector(15 downto 0)
  );
end entity pkt_len_validator;

architecture rtl of pkt_len_validator is
begin
  -- Your implementation here

end architecture rtl;
