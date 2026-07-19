library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dot_product is
  generic (
    DATA_WIDTH : integer := 8;
    MAX_SIZE : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    vec_a_valid : in std_logic;
    vec_a_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    vec_a_last : in std_logic;
    vec_b_valid : in std_logic;
    vec_b_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    vec_b_last : in std_logic;
    out_ready : in std_logic;
    vec_a_ready : out std_logic;
    vec_b_ready : out std_logic;
    out_valid : out std_logic;
    out_result : out std_logic_vector(DATA_WIDTH*2+7 downto 0)
  );
end entity dot_product;

architecture rtl of dot_product is
  constant RESULT_WIDTH : integer := DATA_WIDTH*2 + 8;

  constant IDLE    : std_logic_vector(1 downto 0) := "00";
  constant INPUT_A : std_logic_vector(1 downto 0) := "01";
  constant INPUT_B : std_logic_vector(1 downto 0) := "10";
  constant OUTPUT  : std_logic_vector(1 downto 0) := "11";

  type va_t is array(0 to MAX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal vec_a : va_t;

  signal state       : std_logic_vector(1 downto 0);
  signal next_state  : std_logic_vector(1 downto 0);
  signal vec_a_count : integer range 0 to MAX_SIZE;
  signal vec_b_idx   : integer range 0 to MAX_SIZE;
  signal accum       : unsigned(RESULT_WIDTH-1 downto 0);
  signal a_ready_s, b_ready_s, out_valid_s : std_logic;
begin
  a_ready_s   <= '1' when state = INPUT_A else '0';
  b_ready_s   <= '1' when state = INPUT_B else '0';
  out_valid_s <= '1' when state = OUTPUT  else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, start, vec_a_valid, a_ready_s, vec_a_last,
          vec_b_valid, b_ready_s, vec_b_last, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= INPUT_A; end if;
      when INPUT_A =>
        if vec_a_valid = '1' and a_ready_s = '1' and vec_a_last = '1' then next_state <= INPUT_B; end if;
      when INPUT_B =>
        if vec_b_valid = '1' and b_ready_s = '1' and vec_b_last = '1' then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        vec_a_count <= 0;
        vec_b_idx   <= 0;
        accum       <= (others => '0');
      else
        -- keyed off the registered state so it cannot race the start pulse
        if state = IDLE then
          vec_a_count <= 0;
          vec_b_idx   <= 0;
          accum       <= (others => '0');
        elsif state = INPUT_A and vec_a_valid = '1' and a_ready_s = '1' then
          vec_a(vec_a_count) <= vec_a_data;
          vec_a_count <= vec_a_count + 1;
        elsif state = INPUT_B and vec_b_valid = '1' and b_ready_s = '1' then
          accum     <= accum + (unsigned(vec_a(vec_b_idx)) * unsigned(vec_b_data));
          vec_b_idx <= vec_b_idx + 1;
        end if;
      end if;
    end if;
  end process;

  vec_a_ready <= a_ready_s;
  vec_b_ready <= b_ready_s;
  out_valid   <= out_valid_s;
  out_result  <= std_logic_vector(accum);
end architecture rtl;
