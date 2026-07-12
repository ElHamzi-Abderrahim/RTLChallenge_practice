library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity digital_differentiator is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_in : in signed(DATA_WIDTH-1 downto 0);
    data_out : out signed(DATA_WIDTH downto 0)
  );
end entity digital_differentiator;

architecture rtl of digital_differentiator is
  signal prev_data    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal data_out_reg : std_logic_vector(DATA_WIDTH downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      prev_data    <= (others => '0');
      data_out_reg <= (others => '0');
    elsif rising_edge(clk) then
      prev_data <= std_logic_vector(data_in);
      -- sign-extend both operands to DATA_WIDTH+1 then subtract (two's complement bits)
      data_out_reg <= std_logic_vector(
                        unsigned(data_in(DATA_WIDTH-1) & std_logic_vector(data_in))
                        - unsigned(prev_data(DATA_WIDTH-1) & prev_data));
    end if;
  end process;

  data_out <= signed(data_out_reg);
end architecture rtl;
