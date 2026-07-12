library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity crc_calculator is
  generic (
    CRC_WIDTH : integer := 8;
    POLYNOMIAL : integer := 8
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_valid : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    start : in std_logic;
    crc_out : out std_logic_vector(CRC_WIDTH-1 downto 0);
    crc_valid : out std_logic
  );
end entity crc_calculator;

architecture rtl of crc_calculator is
  signal crc_reg       : std_logic_vector(CRC_WIDTH-1 downto 0);
  signal crc_valid_reg : std_logic;
begin
  process(clk)
    variable crc_temp : std_logic_vector(CRC_WIDTH-1 downto 0);
    variable i        : integer;
  begin
    if rising_edge(clk) then
      if reset = '1' or start = '1' then
        crc_reg       <= (others => '0');
        crc_valid_reg <= '0';
      elsif data_valid = '1' then
        crc_temp := crc_reg xor data_in;
        i := 0;
        while i < 8 loop
          if crc_temp(CRC_WIDTH-1) = '1' then
            crc_temp := std_logic_vector(shift_left(unsigned(crc_temp), 1) xor
                                         to_unsigned(POLYNOMIAL, CRC_WIDTH));
          else
            crc_temp := std_logic_vector(shift_left(unsigned(crc_temp), 1));
          end if;
          i := i + 1;
        end loop;
        crc_reg       <= crc_temp;
        crc_valid_reg <= '1';
      end if;
    end if;
  end process;

  crc_out   <= crc_reg;
  crc_valid <= crc_valid_reg;
end architecture rtl;
