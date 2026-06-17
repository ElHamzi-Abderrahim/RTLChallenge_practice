library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fib_gen is
  generic (
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    out_ready : in std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_index : out std_logic_vector(7 downto 0)
  );
end entity fib_gen;

architecture rtl of fib_gen is
begin
  -- Your implementation here

end architecture rtl;
