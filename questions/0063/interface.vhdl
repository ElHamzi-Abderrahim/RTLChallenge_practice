library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity prime_check is
  generic (
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_num : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_is_prime : out std_logic
  );
end entity prime_check;

architecture rtl of prime_check is
begin
  -- Your implementation here

end architecture rtl;
