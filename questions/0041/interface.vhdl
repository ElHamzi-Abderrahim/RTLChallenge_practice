library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hamming_encoder is
  generic (
    DATA_BITS : integer := 4;
    PARITY_BITS : integer := 3;
    TOTAL_BITS : integer := 7
  );
  port (
    data_in : in std_logic_vector(DATA_BITS-1 downto 0);
    encoded_out : out std_logic_vector(TOTAL_BITS-1 downto 0);
    parity_bits : out std_logic_vector(PARITY_BITS-1 downto 0)
  );
end entity hamming_encoder;

architecture rtl of hamming_encoder is
begin
  -- Your implementation here

end architecture rtl;
