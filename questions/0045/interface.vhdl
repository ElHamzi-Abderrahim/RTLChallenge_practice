library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity carry_lookahead_adder is
  generic (
    WIDTH : integer := 4
  );
  port (
    a_in : in std_logic_vector(WIDTH-1 downto 0);
    b_in : in std_logic_vector(WIDTH-1 downto 0);
    c_in : in std_logic;
    sum_out : out std_logic_vector(WIDTH-1 downto 0);
    c_out : out std_logic
  );
end entity carry_lookahead_adder;

architecture rtl of carry_lookahead_adder is
begin
  -- Your implementation here

end architecture rtl;
