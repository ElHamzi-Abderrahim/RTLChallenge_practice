library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity binary_to_bcd is
  generic (
    BINARY_WIDTH : integer := 8;
    BCD_DIGITS : integer := 3;
    BCD_WIDTH : integer := 12
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    start : in std_logic;
    binary_in : in std_logic_vector(BINARY_WIDTH-1 downto 0);
    bcd_out : out std_logic_vector(BCD_WIDTH-1 downto 0);
    valid : out std_logic
  );
end entity binary_to_bcd;

architecture rtl of binary_to_bcd is
  signal bcd_reg    : std_logic_vector(BCD_WIDTH-1 downto 0);
  signal binary_reg : std_logic_vector(BINARY_WIDTH-1 downto 0);
  signal bit_count  : unsigned(4 downto 0);
  signal busy       : std_logic;
begin
  process(clk)
    variable bcd_v : unsigned(BCD_WIDTH-1 downto 0);
    variable j     : integer;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        bcd_reg    <= (others => '0');
        binary_reg <= (others => '0');
        bit_count  <= (others => '0');
        busy       <= '0';
      elsif start = '1' and busy = '0' then
        bcd_reg    <= (others => '0');
        binary_reg <= binary_in;
        bit_count  <= to_unsigned(BINARY_WIDTH, 5);
        busy       <= '1';
      elsif busy = '1' then
        if bit_count > 0 then
          bcd_v := unsigned(bcd_reg);
          j := 0;
          while j < BCD_DIGITS loop
            if bcd_v(j*4+3 downto j*4) >= 5 then
              bcd_v(j*4+3 downto j*4) := bcd_v(j*4+3 downto j*4) + 3;
            end if;
            j := j + 1;
          end loop;
          bcd_reg    <= std_logic_vector(bcd_v(BCD_WIDTH-2 downto 0)) & binary_reg(BINARY_WIDTH-1);
          binary_reg <= binary_reg(BINARY_WIDTH-2 downto 0) & '0';
          bit_count  <= bit_count - 1;
        else
          busy <= '0';
        end if;
      end if;
    end if;
  end process;

  bcd_out <= bcd_reg;
  valid   <= not busy;
end architecture rtl;
