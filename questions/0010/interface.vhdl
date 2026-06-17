library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity simple_alu is
  port (
    a_i : in std_logic_vector(7 downto 0);
    b_i : in std_logic_vector(7 downto 0);
    op_i : in std_logic_vector(2 downto 0);
    alu_o : out std_logic_vector(7 downto 0)
  );
end entity simple_alu;

architecture rtl of simple_alu is
begin
  -- Your implementation here

end architecture rtl;
