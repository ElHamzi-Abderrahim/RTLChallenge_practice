library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity simple_mux is
  generic (
    DATA_WIDTH : integer := 8;
    SELECT_WIDTH : integer := 2
  );
  port (
    data_in : in std_logic_vector(DATA_WIDTH*(2**SELECT_WIDTH)-1 downto 0);
    select : in std_logic_vector(SELECT_WIDTH-1 downto 0);
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity simple_mux;

architecture rtl of simple_mux is
begin
  -- Your implementation here

end architecture rtl;
