library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dot_product is
  generic (
    DATA_WIDTH : integer := 8;
    MAX_SIZE : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    vec_a_valid : in std_logic;
    vec_a_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    vec_a_last : in std_logic;
    vec_b_valid : in std_logic;
    vec_b_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    vec_b_last : in std_logic;
    out_ready : in std_logic;
    vec_a_ready : out std_logic;
    vec_b_ready : out std_logic;
    out_valid : out std_logic;
    out_result : out std_logic_vector(DATA_WIDTH*2+7 downto 0)
  );
end entity dot_product;

architecture rtl of dot_product is
begin
  -- Your implementation here

end architecture rtl;
