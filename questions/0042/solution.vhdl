library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity population_counter is
  generic (
    INPUT_WIDTH : integer := 8;
    COUNT_WIDTH : integer := 4
  );
  port (
    data_in : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    count_out : out std_logic_vector(COUNT_WIDTH-1 downto 0)
  );
end entity population_counter;

architecture rtl of population_counter is
begin
  process(data_in)
    variable cnt : integer;
    variable i   : integer;
  begin
    cnt := 0;
    i := 0;
    while i < INPUT_WIDTH loop
      if data_in(i) = '1' then
        cnt := cnt + 1;
      end if;
      i := i + 1;
    end loop;
    count_out <= std_logic_vector(to_unsigned(cnt, COUNT_WIDTH));
  end process;
end architecture rtl;
