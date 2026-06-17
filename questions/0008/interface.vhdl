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
  -- Your implementation here

end architecture rtl;
