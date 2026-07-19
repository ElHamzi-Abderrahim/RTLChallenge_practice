library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity insertion_sort is
  generic (
    DATA_WIDTH : integer := 8;
    MAX_SIZE : integer := 8
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
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_last : out std_logic
  );
end entity insertion_sort;

architecture rtl of insertion_sort is
  constant IDLE   : std_logic_vector(2 downto 0) := "000";
  constant INPUT  : std_logic_vector(2 downto 0) := "001";
  constant SORT   : std_logic_vector(2 downto 0) := "010";
  constant SHIFT  : std_logic_vector(2 downto 0) := "011";
  constant OUTPUT : std_logic_vector(2 downto 0) := "100";

  type buf_t is array(0 to MAX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal data_buf : buf_t;

  signal state      : std_logic_vector(2 downto 0);
  signal next_state : std_logic_vector(2 downto 0);
  signal buf_count  : integer range 0 to MAX_SIZE;
  signal sort_i     : integer range 0 to MAX_SIZE;
  -- jp = sort_j + 1, so the index stays non-negative
  signal jp         : integer range 0 to MAX_SIZE;
  signal jm1        : integer range 0 to MAX_SIZE-1;
  signal key        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal out_idx    : integer range 0 to MAX_SIZE;
  signal shift_more : std_logic;
  signal in_ready_s, out_valid_s, out_last_s : std_logic;
begin
  jm1 <= jp - 1 when jp >= 1 else 0;
  shift_more <= '1' when (jp >= 1 and unsigned(data_buf(jm1)) > unsigned(key)) else '0';

  in_ready_s  <= '1' when state = INPUT  else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';
  out_last_s  <= '1' when (state = OUTPUT and out_idx = buf_count - 1) else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, start, in_valid, in_ready_s, in_last, sort_i, buf_count,
          shift_more, out_valid_s, out_ready, out_last_s)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= INPUT; end if;
      when INPUT =>
        if in_valid = '1' and in_ready_s = '1' and in_last = '1' then next_state <= SORT; end if;
      when SORT =>
        if sort_i >= buf_count then next_state <= OUTPUT; else next_state <= SHIFT; end if;
      when SHIFT =>
        if shift_more = '0' then next_state <= SORT; end if;
      when OUTPUT =>
        if out_valid_s = '1' and out_ready = '1' and out_last_s = '1' then next_state <= IDLE; end if;
      when others =>
        next_state <= IDLE;
    end case;
  end process;

  -- single datapath process (data_buf has one driver)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        buf_count <= 0;
        sort_i    <= 1;
        jp        <= 0;
        key       <= (others => '0');
        out_idx   <= 0;
      else
        -- input capture
        if start = '1' then
          buf_count <= 0;
        elsif state = INPUT and in_valid = '1' and in_ready_s = '1' then
          data_buf(buf_count) <= in_data;
          buf_count <= buf_count + 1;
        end if;

        -- insertion sort
        if state = INPUT and in_valid = '1' and in_ready_s = '1' and in_last = '1' then
          sort_i <= 1;
          jp     <= 0;
          key    <= (others => '0');
        elsif state = SORT then
          if sort_i < buf_count then
            key <= data_buf(sort_i);
            jp  <= sort_i;
          end if;
        elsif state = SHIFT then
          if shift_more = '1' then
            data_buf(jp) <= data_buf(jm1);
            jp <= jp - 1;
          else
            data_buf(jp) <= key;
            sort_i <= sort_i + 1;
          end if;
        end if;

        -- output index
        if state = SORT and sort_i >= buf_count then
          out_idx <= 0;
        elsif state = OUTPUT and out_valid_s = '1' and out_ready = '1' then
          out_idx <= out_idx + 1;
        end if;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_data  <= data_buf(out_idx);
  out_last  <= out_last_s;
end architecture rtl;
