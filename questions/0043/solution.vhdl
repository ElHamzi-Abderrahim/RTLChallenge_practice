library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity leading_zero_counter is
  generic (
    INPUT_WIDTH : integer := 8;
    COUNT_WIDTH : integer := 4
  );
  port (
    data_in : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    zero_count : out std_logic_vector(COUNT_WIDTH-1 downto 0);
    all_zero : out std_logic
  );
end entity leading_zero_counter;

architecture rtl of leading_zero_counter is
begin
  process(data_in)
    variable cnt   : integer;
    variable found : std_logic;
    variable i     : integer;
  begin
    cnt := 0;
    found := '0';
    i := 0;
    while i < INPUT_WIDTH loop
      if found = '0' then
        if data_in(INPUT_WIDTH-1-i) = '1' then
          found := '1';
        else
          cnt := cnt + 1;
        end if;
      end if;
      i := i + 1;
    end loop;
    zero_count <= std_logic_vector(to_unsigned(cnt, COUNT_WIDTH));
    if cnt = INPUT_WIDTH then
      all_zero <= '1';
    else
      all_zero <= '0';
    end if;
  end process;
end architecture rtl;
