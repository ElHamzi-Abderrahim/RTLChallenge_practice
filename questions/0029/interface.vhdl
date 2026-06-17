library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Universal_Shift_Register is
  port (
    clk : in std_logic;
    reset : in std_logic;
    load : in std_logic;
    shift_left : in std_logic;
    shift_right : in std_logic;
    serial_in : in std_logic;
    enable : in std_logic;
    q : out std_logic_vector(3 downto 0)
  );
end entity Universal_Shift_Register;

architecture rtl of Universal_Shift_Register is
begin
  -- Your implementation here

end architecture rtl;
