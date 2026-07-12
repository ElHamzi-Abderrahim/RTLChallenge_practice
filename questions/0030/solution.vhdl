library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lifo is
  port (
    clk : in std_logic;
    reset : in std_logic;
    push : in std_logic;
    pop : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0)
  );
end entity lifo;

architecture rtl of lifo is
  type stack_t is array(0 to 3) of std_logic_vector(7 downto 0);
  signal stack   : stack_t;
  signal top     : unsigned(2 downto 0);
  signal out_reg : std_logic_vector(7 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      top      <= (others => '0');
      stack(0) <= (others => '0');
      stack(1) <= (others => '0');
      stack(2) <= (others => '0');
      stack(3) <= (others => '0');
      out_reg  <= (others => '0');
    elsif rising_edge(clk) then
      if push = '1' and pop = '0' then
        if top < 4 then
          stack(to_integer(top)) <= data_in;
          top <= top + 1;
        end if;
      elsif pop = '1' and push = '0' then
        if top > 0 then
          top     <= top - 1;
          out_reg <= stack(to_integer(top - 1));
        else
          out_reg <= (others => '0');
        end if;
      elsif push = '1' and pop = '1' then
        if top < 4 then
          stack(to_integer(top)) <= data_in;
          top <= top + 1;
        end if;
      end if;
    end if;
  end process;

  data_out <= out_reg;
end architecture rtl;
