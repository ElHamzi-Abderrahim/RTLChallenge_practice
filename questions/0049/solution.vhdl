library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity iir_biquad is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_in : in signed(DATA_WIDTH-1 downto 0);
    data_out : out signed(DATA_WIDTH-1 downto 0)
  );
end entity iir_biquad;

architecture rtl of iir_biquad is
  signal x1    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal x2    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal y1    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal y_out : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
  process(clk, reset)
    variable din  : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable se_in, se_x1, se_x2, se_y1, acc, ashr : std_logic_vector(DATA_WIDTH+3 downto 0);
    variable yt : std_logic_vector(DATA_WIDTH-1 downto 0);
  begin
    if reset = '1' then
      x1    <= (others => '0');
      x2    <= (others => '0');
      y1    <= (others => '0');
      y_out <= (others => '0');
    elsif rising_edge(clk) then
      din := std_logic_vector(data_in);
      se_in := din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din;
      se_x1 := x1(DATA_WIDTH-1) & x1(DATA_WIDTH-1) & x1(DATA_WIDTH-1) & x1 & '0';
      se_x2 := x2(DATA_WIDTH-1) & x2(DATA_WIDTH-1) & x2(DATA_WIDTH-1) & x2(DATA_WIDTH-1) & x2;
      se_y1 := y1(DATA_WIDTH-1) & y1(DATA_WIDTH-1) & y1(DATA_WIDTH-1) & y1(DATA_WIDTH-1) & y1;
      acc := std_logic_vector(unsigned(se_in) + unsigned(se_x1) + unsigned(se_x2) - unsigned(se_y1));

      if acc(DATA_WIDTH+3 downto DATA_WIDTH+2) = "01" then
        yt := (others => '1');
        yt(DATA_WIDTH-1) := '0';
      elsif acc(DATA_WIDTH+3 downto DATA_WIDTH+2) = "10" then
        yt := (others => '0');
        yt(DATA_WIDTH-1) := '1';
      else
        ashr := acc(DATA_WIDTH+3) & acc(DATA_WIDTH+3) & acc(DATA_WIDTH+3) & acc(DATA_WIDTH+3 downto 3);
        yt := ashr(DATA_WIDTH-1 downto 0);
      end if;

      x2    <= x1;
      x1    <= din;
      y1    <= yt;
      y_out <= yt;
    end if;
  end process;

  data_out <= signed(y_out);
end architecture rtl;
