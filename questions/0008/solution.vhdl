library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity d_flip_flop is
  port (
    clk : in std_logic;
    reset : in std_logic;
    d_i : in std_logic;
    q_norst_o : out std_logic;
    q_syncrst_o : out std_logic;
    q_asyncrst_o : out std_logic
  );
end entity d_flip_flop;

architecture rtl of d_flip_flop is
begin
  -- Non-resettable flip-flop
  process(clk)
  begin
    if rising_edge(clk) then
      q_norst_o <= d_i;
    end if;
  end process;

  -- Synchronous reset flip-flop
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        q_syncrst_o <= '0';
      else
        q_syncrst_o <= d_i;
      end if;
    end if;
  end process;

  -- Asynchronous reset flip-flop
  process(clk, reset)
  begin
    if reset = '1' then
      q_asyncrst_o <= '0';
    elsif rising_edge(clk) then
      q_asyncrst_o <= d_i;
    end if;
  end process;
end architecture rtl;
