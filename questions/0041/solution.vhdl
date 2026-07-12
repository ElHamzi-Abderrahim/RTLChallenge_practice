library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hamming_encoder is
  port (
    data_in : in std_logic_vector(7 downto 0);
    encoded_out : out std_logic_vector(12 downto 0);
    parity_bits : out std_logic_vector(4 downto 0)
  );
end entity hamming_encoder;

architecture rtl of hamming_encoder is
  signal p0, p1, p2, p3, p4 : std_logic;
  signal d0, d1, d2, d3, d4, d5, d6, d7 : std_logic;
begin
  d0 <= data_in(0);
  d1 <= data_in(1);
  d2 <= data_in(2);
  d3 <= data_in(3);
  d4 <= data_in(4);
  d5 <= data_in(5);
  d6 <= data_in(6);
  d7 <= data_in(7);

  p0 <= d0 xor d1 xor d3 xor d4 xor d6;
  p1 <= d0 xor d2 xor d3 xor d5 xor d6;
  p2 <= d1 xor d2 xor d3 xor d7;
  p3 <= d4 xor d5 xor d6 xor d7;
  p4 <= p0 xor p1 xor d0 xor p2 xor d1 xor d2 xor d3 xor p3 xor d4 xor d5 xor d6 xor d7;

  encoded_out <= p4 & d7 & d6 & d5 & d4 & p3 & d3 & d2 & d1 & p2 & d0 & p1 & p0;
  parity_bits <= p4 & p3 & p2 & p1 & p0;
end architecture rtl;
