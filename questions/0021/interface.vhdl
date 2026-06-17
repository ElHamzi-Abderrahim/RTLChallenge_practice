library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity round_robin_arbiter is
  port (
    clk : in std_logic;
    reset : in std_logic;
    req_i : in std_logic_vector(3 downto 0);
    gnt_o : out std_logic_vector(3 downto 0)
  );
end entity round_robin_arbiter;

architecture rtl of round_robin_arbiter is
begin
  -- Your implementation here

end architecture rtl;
