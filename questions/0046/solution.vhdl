library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fir_filter is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_in : in signed(DATA_WIDTH-1 downto 0);
    data_out : out signed(DATA_WIDTH+1 downto 0)
  );
end entity fir_filter;

architecture rtl of fir_filter is
  signal delay1      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal delay2      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal delay3      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal accumulator : std_logic_vector(DATA_WIDTH+3 downto 0);
begin
  process(clk, reset)
    variable din  : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable se_in, se_d1, se_d2, se_d3, s, ashr : std_logic_vector(DATA_WIDTH+3 downto 0);
  begin
    if reset = '1' then
      delay1      <= (others => '0');
      delay2      <= (others => '0');
      delay3      <= (others => '0');
      accumulator <= (others => '0');
    elsif rising_edge(clk) then
      din := std_logic_vector(data_in);
      delay1 <= din;
      delay2 <= delay1;
      delay3 <= delay2;
      -- sign-extend to DATA_WIDTH+4 bits; multiply-by-2 terms append a '0'
      se_in := din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din;
      se_d1 := delay1(DATA_WIDTH-1) & delay1(DATA_WIDTH-1) & delay1(DATA_WIDTH-1) & delay1 & '0';
      se_d2 := delay2(DATA_WIDTH-1) & delay2(DATA_WIDTH-1) & delay2(DATA_WIDTH-1) & delay2 & '0';
      se_d3 := delay3(DATA_WIDTH-1) & delay3(DATA_WIDTH-1) & delay3(DATA_WIDTH-1) & delay3(DATA_WIDTH-1) & delay3;
      s := std_logic_vector(unsigned(se_in) + unsigned(se_d1) + unsigned(se_d2) + unsigned(se_d3));
      -- arithmetic shift right by 3
      ashr := s(DATA_WIDTH+3) & s(DATA_WIDTH+3) & s(DATA_WIDTH+3) & s(DATA_WIDTH+3 downto 3);
      accumulator <= ashr;
    end if;
  end process;

  data_out <= signed(accumulator(DATA_WIDTH+1 downto 0));
end architecture rtl;
