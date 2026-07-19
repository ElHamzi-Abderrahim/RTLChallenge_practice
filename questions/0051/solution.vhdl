library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gray_to_binary is
  generic (
    WIDTH : integer := 4
  );
  port (
    gray_in : in std_logic_vector(WIDTH-1 downto 0);
    binary_out : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity gray_to_binary;

architecture rtl of gray_to_binary is
begin
  process(gray_in)
    variable b : std_logic_vector(WIDTH-1 downto 0);
    variable k : integer;
  begin
    b(WIDTH-1) := gray_in(WIDTH-1);
    k := 1;
    while k < WIDTH loop
      b(WIDTH-1-k) := b(WIDTH-k) xor gray_in(WIDTH-1-k);
      k := k + 1;
    end loop;
    binary_out <= b;
  end process;
end architecture rtl;
