library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity parity_gen_check is
  generic (
    DATA_WIDTH : integer := 8;
    PARITY_TYPE : integer := 0
  );
  port (
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    mode : in std_logic;
    parity_in : in std_logic;
    parity_out : out std_logic;
    err : out std_logic
  );
end entity parity_gen_check;

architecture rtl of parity_gen_check is
begin
  process(data_in, parity_in)
    variable p : std_logic;
    variable i : integer;
  begin
    p := '0';
    i := 0;
    while i < DATA_WIDTH loop
      p := p xor data_in(i);
      i := i + 1;
    end loop;
    if PARITY_TYPE = 0 then
      parity_out <= p;
      err <= p xor parity_in;
    else
      parity_out <= not p;
      err <= not (p xor parity_in);
    end if;
  end process;
end architecture rtl;
