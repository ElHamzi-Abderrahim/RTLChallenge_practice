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
  process(a_i, b_i, op_i)
  begin
    case op_i is
      when "000" => alu_o <= std_logic_vector(unsigned(a_i) + unsigned(b_i));  -- ADD
      when "001" => alu_o <= std_logic_vector(unsigned(a_i) - unsigned(b_i));  -- SUB
      when "010" => alu_o <= a_i and b_i;                                      -- AND
      when "011" => alu_o <= a_i or b_i;                                       -- OR
      when "100" => alu_o <= a_i xor b_i;                                      -- XOR
      when "101" => alu_o <= not a_i;                                          -- NOT
      when "110" => alu_o <= a_i(6 downto 0) & '0';                            -- SLL
      when "111" => alu_o <= '0' & a_i(7 downto 1);                            -- SRL
      when others => alu_o <= (others => '0');
    end case;
  end process;
end architecture rtl;
