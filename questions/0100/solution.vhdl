library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity argmax_unit is
  generic (
    DATA_WIDTH : integer := 8;
    MAX_SIZE : integer := 16
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
    out_argmax : out std_logic_vector(7 downto 0);
    out_max : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity argmax_unit;

architecture rtl of argmax_unit is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant SEARCH : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal curr_idx   : unsigned(7 downto 0);
  signal max_idx    : unsigned(7 downto 0);
  signal max_val    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal in_ready_s, out_valid_s, consume : std_logic;
begin
  in_ready_s  <= '1' when state = SEARCH else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';
  consume     <= '1' when (state = SEARCH and in_valid = '1') else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, start, consume, in_last, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= SEARCH; end if;
      when SEARCH =>
        if consume = '1' and in_last = '1' then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        curr_idx <= (others => '0');
        max_idx  <= (others => '0');
        max_val  <= (others => '0');
      elsif state = IDLE and next_state = SEARCH then
        curr_idx <= (others => '0');
        max_idx  <= (others => '0');
        max_val  <= (others => '0');
      elsif consume = '1' then
        if curr_idx = 0 or unsigned(in_data) > unsigned(max_val) then
          max_val <= in_data;
          max_idx <= curr_idx;
        end if;
        curr_idx <= curr_idx + 1;
      end if;
    end if;
  end process;

  in_ready   <= in_ready_s;
  out_valid  <= out_valid_s;
  out_argmax <= std_logic_vector(max_idx);
  out_max    <= max_val;
end architecture rtl;
