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
  signal sum_ext : unsigned(WIDTH downto 0);
begin
  process(a_in, b_in, c_in)
    variable cin_v : unsigned(WIDTH downto 0);
  begin
    if c_in = '1' then
      cin_v := to_unsigned(1, WIDTH+1);
    else
      cin_v := to_unsigned(0, WIDTH+1);
    end if;
    sum_ext <= resize(unsigned(a_in), WIDTH+1) + resize(unsigned(b_in), WIDTH+1) + cin_v;
  end process;

  sum_out <= std_logic_vector(sum_ext(WIDTH-1 downto 0));
  c_out   <= sum_ext(WIDTH);
end architecture rtl;
