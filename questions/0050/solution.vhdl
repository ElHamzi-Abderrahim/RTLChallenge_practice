library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decimation_filter is
  generic (
    DATA_WIDTH : integer := 8;
    DECIMATION_FACTOR : integer := 4
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    data_in : in signed(DATA_WIDTH-1 downto 0);
    data_valid_in : in std_logic;
    data_out : out signed(DATA_WIDTH-1 downto 0);
    data_valid_out : out std_logic
  );
end entity decimation_filter;

architecture rtl of decimation_filter is
  signal x1 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal x2 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal x3 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sample_counter : integer range 0 to DECIMATION_FACTOR-1;
  signal valid_out_reg  : std_logic;
  signal output_reg     : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
  process(clk)
    variable din  : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable se_in, se_x1, se_x2, se_x3, filt, ashr : std_logic_vector(DATA_WIDTH+3 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' then
        x1 <= (others => '0');
        x2 <= (others => '0');
        x3 <= (others => '0');
        sample_counter <= 0;
        valid_out_reg  <= '0';
        output_reg     <= (others => '0');
      elsif data_valid_in = '1' then
        din := std_logic_vector(data_in);
        x3 <= x2;
        x2 <= x1;
        x1 <= din;
        -- filtered = data_in + 3*x1 + 3*x2 + x3  (coeffs 1,3,3,1)
        se_in := din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din(DATA_WIDTH-1) & din;
        se_x1 := x1(DATA_WIDTH-1) & x1(DATA_WIDTH-1) & x1(DATA_WIDTH-1) & x1(DATA_WIDTH-1) & x1;
        se_x2 := x2(DATA_WIDTH-1) & x2(DATA_WIDTH-1) & x2(DATA_WIDTH-1) & x2(DATA_WIDTH-1) & x2;
        se_x3 := x3(DATA_WIDTH-1) & x3(DATA_WIDTH-1) & x3(DATA_WIDTH-1) & x3(DATA_WIDTH-1) & x3;
        filt := std_logic_vector(unsigned(se_in)
                + unsigned(se_x1) + unsigned(se_x1) + unsigned(se_x1)
                + unsigned(se_x2) + unsigned(se_x2) + unsigned(se_x2)
                + unsigned(se_x3));
        if sample_counter = DECIMATION_FACTOR-1 then
          sample_counter <= 0;
          valid_out_reg  <= '1';
          ashr := filt(DATA_WIDTH+3) & filt(DATA_WIDTH+3) & filt(DATA_WIDTH+3) & filt(DATA_WIDTH+3 downto 3);
          output_reg <= ashr(DATA_WIDTH-1 downto 0);
        else
          sample_counter <= sample_counter + 1;
          valid_out_reg  <= '0';
        end if;
      else
        valid_out_reg <= '0';
      end if;
    end if;
  end process;

  data_out       <= signed(output_reg);
  data_valid_out <= valid_out_reg;
end architecture rtl;
