library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dual_edge_dff is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity dual_edge_dff;

architecture rtl of dual_edge_dff is
  signal d_in_pos  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal q_out_pos : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal d_in_neg  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal q_out_neg : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal clk_n     : std_logic;
begin
  clk_n <= not clk;  -- Invert clock for negative edge latching

  d_in_pos <= data_in xor q_out_neg;
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      q_out_pos <= (others => '0');
    elsif rising_edge(clk) then
      q_out_pos <= d_in_pos;
    end if;
  end process;

  d_in_neg <= data_in xor q_out_pos;
  process(clk_n, rst_n)
  begin
    if rst_n = '0' then
      q_out_neg <= (others => '0');
    elsif rising_edge(clk_n) then
      q_out_neg <= d_in_neg;
    end if;
  end process;

  data_out <= q_out_pos xor q_out_neg;
end architecture rtl;
