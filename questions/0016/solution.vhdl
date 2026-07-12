library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity self_reload_counter is
  port (
    clk : in std_logic;
    reset : in std_logic;
    load_i : in std_logic;
    load_val_i : in std_logic_vector(3 downto 0);
    count_o : out std_logic_vector(3 downto 0)
  );
end entity self_reload_counter;

architecture rtl of self_reload_counter is
  signal count_reg  : unsigned(3 downto 0);
  signal reload_val : unsigned(3 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      count_reg  <= (others => '0');
      reload_val <= (others => '0');
    elsif rising_edge(clk) then
      if load_i = '1' then
        count_reg  <= unsigned(load_val_i);
        reload_val <= unsigned(load_val_i);
      elsif count_reg = x"F" then
        count_reg <= reload_val;
      else
        count_reg <= count_reg + 1;
      end if;
    end if;
  end process;

  count_o <= std_logic_vector(count_reg);
end architecture rtl;
