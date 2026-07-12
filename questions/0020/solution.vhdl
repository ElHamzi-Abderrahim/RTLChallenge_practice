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
  -- Grant the lowest-index requesting port: gnt = req AND (two's complement of req)
  gnt_o <= std_logic_vector(unsigned(req_i) and (not unsigned(req_i)) + 1);
end architecture rtl;
