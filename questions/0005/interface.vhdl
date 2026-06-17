library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sequence_detector is
  generic (
    PATTERN : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    data_in : in std_logic;
    pattern_detected : out std_logic
  );
end entity sequence_detector;

architecture rtl of sequence_detector is
begin
  -- Your implementation here

end architecture rtl;
