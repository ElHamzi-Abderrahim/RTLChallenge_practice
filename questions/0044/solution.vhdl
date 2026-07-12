library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity thermometer_to_binary is
  generic (
    THERMO_WIDTH : integer := 7;
    BINARY_WIDTH : integer := 3
  );
  port (
    thermo_in : in std_logic_vector(THERMO_WIDTH-1 downto 0);
    binary_out : out std_logic_vector(BINARY_WIDTH-1 downto 0);
    valid : out std_logic
  );
end entity thermometer_to_binary;

architecture rtl of thermometer_to_binary is
begin
  process(thermo_in)
    variable cnt : integer;
    variable isv : std_logic;
    variable fz  : std_logic;
    variable i   : integer;
  begin
    cnt := 0;
    isv := '1';
    fz := '0';
    i := 0;
    while i < THERMO_WIDTH loop
      if thermo_in(i) = '1' then
        if fz = '1' then
          isv := '0';
        end if;
        cnt := cnt + 1;
      else
        fz := '1';
      end if;
      i := i + 1;
    end loop;
    binary_out <= std_logic_vector(to_unsigned(cnt, BINARY_WIDTH));
    valid <= isv;
  end process;
end architecture rtl;
