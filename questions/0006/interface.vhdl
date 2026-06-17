library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dual_edge_dff is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity dual_edge_dff;

architecture rtl of dual_edge_dff is
begin
  -- Your implementation here

end architecture rtl;
