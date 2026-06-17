library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity factorial is
  generic (
    DATA_WIDTH : integer := 32;
    INPUT_WIDTH : integer := 5
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_n : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_factorial : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity factorial;

architecture rtl of factorial is
begin
  -- Your implementation here

end architecture rtl;
