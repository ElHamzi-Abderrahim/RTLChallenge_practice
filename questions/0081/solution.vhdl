library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity stream_accum is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_sum : out std_logic_vector(DATA_WIDTH+7 downto 0)
  );
end entity stream_accum;

architecture rtl of stream_accum is
  constant SUM_WIDTH : integer := DATA_WIDTH + 8;

  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant INPUT  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state       : std_logic_vector(1 downto 0);
  signal next_state  : std_logic_vector(1 downto 0);
  signal sum_reg     : unsigned(SUM_WIDTH-1 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
begin
  in_ready_s  <= '1' when state = INPUT  else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';

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

  process(state, start, in_valid, in_ready_s, in_last, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= INPUT; end if;
      when INPUT =>
        if in_valid = '1' and in_ready_s = '1' and in_last = '1' then next_state <= OUTPUT; end if;
      when OUTPUT =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
      when others =>
        next_state <= IDLE;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        sum_reg <= (others => '0');
      elsif start = '1' then
        sum_reg <= (others => '0');
      elsif state = INPUT and in_valid = '1' and in_ready_s = '1' then
        sum_reg <= sum_reg + unsigned(x"00" & in_data);
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_sum   <= std_logic_vector(sum_reg);
end architecture rtl;
