library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UpDownCounter is
  port (
    clk : in std_logic;
    rst : in std_logic;
    up_down : in std_logic;
    count : out std_logic_vector(3 downto 0)
  );
end entity UpDownCounter;

architecture rtl of UpDownCounter is
begin
  -- Your implementation here

end architecture rtl;
