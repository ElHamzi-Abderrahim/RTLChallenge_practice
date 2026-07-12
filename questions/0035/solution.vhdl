library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrel_shifter is
  generic (
    DATA_WIDTH : integer := 8;
    SHIFT_WIDTH : integer := 3
  );
  port (
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    shift_amt : in std_logic_vector(SHIFT_WIDTH-1 downto 0);
    shift_dir : in std_logic;
    shift_type : in std_logic;
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity barrel_shifter;

architecture rtl of barrel_shifter is
  signal shifted_data : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
  process(data_in, shift_amt, shift_dir, shift_type)
    variable amt : integer;
    variable eff : integer;
  begin
    amt := to_integer(unsigned(shift_amt));
    eff := amt mod DATA_WIDTH;
    if shift_dir = '0' then
      if shift_type = '0' then
        shifted_data <= std_logic_vector(shift_left(unsigned(data_in), amt));
      else
        shifted_data <= std_logic_vector(shift_left(unsigned(data_in), eff) or
                                         shift_right(unsigned(data_in), DATA_WIDTH - eff));
      end if;
    else
      if shift_type = '0' then
        shifted_data <= std_logic_vector(shift_right(unsigned(data_in), amt));
      else
        shifted_data <= std_logic_vector(shift_right(unsigned(data_in), eff) or
                                         shift_left(unsigned(data_in), DATA_WIDTH - eff));
      end if;
    end if;
  end process;

  data_out <= shifted_data;
end architecture rtl;
