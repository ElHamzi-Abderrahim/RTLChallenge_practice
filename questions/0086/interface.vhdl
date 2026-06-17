library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hamming_dist is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_a : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_b : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_dist : out std_logic_vector($clog2(DATA_WIDTH+1)-1 downto 0)
  );
end entity hamming_dist;

architecture rtl of hamming_dist is
begin
  -- Your implementation here

end architecture rtl;
