library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity stopwatch_timer is
  port (
    clk : in std_logic;
    reset : in std_logic;
    start : in std_logic;
    clear : in std_logic;
    minutes : out std_logic_vector(5 downto 0);
    seconds : out std_logic_vector(5 downto 0);
    tenths : out std_logic_vector(3 downto 0);
    running : out std_logic
  );
end entity stopwatch_timer;

architecture rtl of stopwatch_timer is
begin
  -- Your implementation here

end architecture rtl;
