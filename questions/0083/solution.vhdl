library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity majority_elem is
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
    out_elem : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_found : out std_logic
  );
end entity majority_elem;

architecture rtl of majority_elem is
  constant MAX_SIZE : integer := 16;

  constant IDLE   : std_logic_vector(2 downto 0) := "000";
  constant VOTE   : std_logic_vector(2 downto 0) := "001";
  constant VERIFY : std_logic_vector(2 downto 0) := "010";
  constant OUTPUT : std_logic_vector(2 downto 0) := "011";

  type buf_t is array(0 to MAX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal data_buf : buf_t;

  signal state      : std_logic_vector(2 downto 0);
  signal next_state : std_logic_vector(2 downto 0);
  signal buf_count  : unsigned(4 downto 0);
  signal verify_idx : unsigned(4 downto 0);
  signal candidate  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal vote_count : unsigned(5 downto 0);
  signal cand_count : unsigned(4 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
begin
  in_ready_s  <= '1' when state = VOTE   else '0';
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

  process(state, start, in_valid, in_ready_s, in_last, verify_idx, buf_count, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= VOTE; end if;
      when VOTE =>
        if in_valid = '1' and in_ready_s = '1' and in_last = '1' then next_state <= VERIFY; end if;
      when VERIFY =>
        if verify_idx >= buf_count then next_state <= OUTPUT; end if;
      when OUTPUT =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
      when others =>
        next_state <= IDLE;
    end case;
  end process;

  -- Boyer-Moore voting and capture
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        candidate  <= (others => '0');
        vote_count <= (others => '0');
        buf_count  <= (others => '0');
      elsif start = '1' then
        candidate  <= (others => '0');
        vote_count <= (others => '0');
        buf_count  <= (others => '0');
      elsif state = VOTE and in_valid = '1' and in_ready_s = '1' then
        data_buf(to_integer(buf_count)) <= in_data;
        buf_count <= buf_count + 1;
        if vote_count = 0 then
          candidate  <= in_data;
          vote_count <= to_unsigned(1, 6);
        elsif in_data = candidate then
          vote_count <= vote_count + 1;
        else
          vote_count <= vote_count - 1;
        end if;
      end if;
    end if;
  end process;

  -- Verification pass
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        verify_idx <= (others => '0');
        cand_count <= (others => '0');
      elsif start = '1' or state = IDLE then
        verify_idx <= (others => '0');
        cand_count <= (others => '0');
      elsif state = VERIFY and verify_idx < buf_count then
        verify_idx <= verify_idx + 1;
        if data_buf(to_integer(verify_idx)) = candidate then
          cand_count <= cand_count + 1;
        end if;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_elem  <= candidate;
  out_found <= '1' when cand_count > shift_right(buf_count, 1) else '0';
end architecture rtl;
