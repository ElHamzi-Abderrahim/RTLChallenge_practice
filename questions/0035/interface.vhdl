library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrel_shifter is
  generic (
    DATA_WIDTH : integer := 8;
    SHIFT_WIDTH : integer := 3
  );
  port (
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    shift_amt : in std_logic_vector(SHIFT_WIDTH-1 downto 0);
    shift_dir : in std_logic;
    shift_type : in std_logic;
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity barrel_shifter;

architecture rtl of barrel_shifter is
begin
  -- Your implementation here

end architecture rtl;
