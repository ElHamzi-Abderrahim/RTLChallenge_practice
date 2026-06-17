library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity priority_arbiter is
  generic (
    NUM_PORTS : integer := 4
  );
  port (
    req_i : in std_logic_vector(NUM_PORTS-1 downto 0);
    gnt_o : out std_logic_vector(NUM_PORTS-1 downto 0)
  );
end entity priority_arbiter;

architecture rtl of priority_arbiter is
begin
  -- Your implementation here

end architecture rtl;
