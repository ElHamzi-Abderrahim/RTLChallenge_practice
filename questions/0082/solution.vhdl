library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity prefix_sum is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH+7 downto 0)
  );
end entity prefix_sum;

architecture rtl of prefix_sum is
  constant SUM_WIDTH : integer := DATA_WIDTH + 8;

  constant IDLE    : std_logic_vector(1 downto 0) := "00";
  constant COMPUTE : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT  : std_logic_vector(1 downto 0) := "10";

  signal state         : std_logic_vector(1 downto 0);
  signal next_state    : std_logic_vector(1 downto 0);
  signal sum_reg       : unsigned(SUM_WIDTH-1 downto 0);
  signal out_reg       : unsigned(SUM_WIDTH-1 downto 0);
  signal out_valid_reg : std_logic;
  signal in_ready_s    : std_logic;
  signal out_valid_s   : std_logic;
begin
  in_ready_s  <= '1' when state = COMPUTE else '0';
  out_valid_s <= out_valid_reg when state = OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state <= IDLE;
      else
        state <= next_state;
      end if;
    end if;
  end process;

  process(state, start, in_valid, in_ready_s, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= COMPUTE; end if;
      when COMPUTE =>
        if in_valid = '1' and in_ready_s = '1' then next_state <= OUTPUT; end if;
      when OUTPUT =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= COMPUTE; end if;
      when others =>
        next_state <= IDLE;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        sum_reg       <= (others => '0');
        out_reg       <= (others => '0');
        out_valid_reg <= '0';
      elsif start = '1' then
        sum_reg       <= (others => '0');
        out_valid_reg <= '0';
      elsif state = COMPUTE and in_valid = '1' and in_ready_s = '1' then
        sum_reg       <= sum_reg + unsigned(x"00" & in_data);
        out_reg       <= sum_reg + unsigned(x"00" & in_data);
        out_valid_reg <= '1';
      elsif state = OUTPUT and out_valid_s = '1' and out_ready = '1' then
        out_valid_reg <= '0';
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_data  <= std_logic_vector(out_reg);
end architecture rtl;
