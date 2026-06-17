library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity parity_gen_check is
  generic (
    DATA_WIDTH : integer := 8;
    PARITY_TYPE : integer := 0
  );
  port (
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    mode : in std_logic;
    parity_in : in std_logic;
    parity_out : out std_logic;
    error : out std_logic
  );
end entity parity_gen_check;

architecture rtl of parity_gen_check is
begin
  -- Your implementation here

end architecture rtl;
