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
begin
  -- Your implementation here

end architecture rtl;
