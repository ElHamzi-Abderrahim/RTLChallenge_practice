library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity edge_detector is
  port (
    clk : in std_logic;
    reset : in std_logic;
    a_i : in std_logic;
    rising_edge_o : out std_logic;
    falling_edge_o : out std_logic
  );
end entity edge_detector;

architecture rtl of edge_detector is
  signal a_prev : std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        a_prev <= '0';
      else
        a_prev <= a_i;
      end if;
    end if;
  end process;

  rising_edge_o  <= a_i and (not a_prev);
  falling_edge_o <= (not a_i) and a_prev;
end architecture rtl;
