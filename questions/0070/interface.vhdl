library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity merge_sorted is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_a_valid : in std_logic;
    in_a_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_a_last : in std_logic;
    in_b_valid : in std_logic;
    in_b_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_b_last : in std_logic;
    out_ready : in std_logic;
    in_a_ready : out std_logic;
    in_b_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_last : out std_logic
  );
end entity merge_sorted;

architecture rtl of merge_sorted is
begin
  -- Your implementation here

end architecture rtl;
