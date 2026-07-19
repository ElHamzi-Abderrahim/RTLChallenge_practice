library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity longest_consec is
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
    out_length : out std_logic_vector(7 downto 0)
  );
end entity longest_consec;

architecture rtl of longest_consec is
  constant IDLE   : std_logic_vector(2 downto 0) := "000";
  constant INPUT  : std_logic_vector(2 downto 0) := "001";
  constant SORT   : std_logic_vector(2 downto 0) := "010";
  constant SCAN   : std_logic_vector(2 downto 0) := "011";
  constant OUTPUT : std_logic_vector(2 downto 0) := "100";

  type buf_t is array(0 to MAX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal data_buf : buf_t;

  signal state       : std_logic_vector(2 downto 0);
  signal next_state  : std_logic_vector(2 downto 0);
  signal buf_count   : integer range 0 to MAX_SIZE;
  signal sort_i      : integer range 0 to MAX_SIZE;
  signal sort_j      : integer range 0 to MAX_SIZE;
  signal sort_swapped : std_logic;
  signal scan_idx    : integer range 0 to MAX_SIZE;
  signal curr_len    : unsigned(7 downto 0);
  signal max_len     : unsigned(7 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
begin
  in_ready_s  <= '1' when state = INPUT  else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, start, in_valid, in_ready_s, in_last, sort_i, buf_count,
          sort_swapped, scan_idx, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= INPUT; end if;
      when INPUT =>
        if in_valid = '1' and in_ready_s = '1' and in_last = '1' then next_state <= SORT; end if;
      when SORT =>
        if sort_i >= buf_count - 1 and sort_swapped = '0' then next_state <= SCAN; end if;
      when SCAN =>
        if scan_idx >= buf_count then next_state <= OUTPUT; end if;
      when OUTPUT =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
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
        sort_i <= 0; sort_j <= 0; sort_swapped <= '0';
        scan_idx <= 0; curr_len <= to_unsigned(1, 8); max_len <= to_unsigned(1, 8);
      else
        -- input capture
        if start = '1' then
          buf_count <= 0;
        elsif state = INPUT and in_valid = '1' and in_ready_s = '1' then
          data_buf(buf_count) <= in_data;
          buf_count <= buf_count + 1;
        end if;

        -- bubble sort
        if state = INPUT and in_valid = '1' and in_ready_s = '1' and in_last = '1' then
          sort_i <= 0; sort_j <= 0; sort_swapped <= '0';
        elsif state = SORT then
          if sort_j < buf_count - 1 - sort_i then
            if unsigned(data_buf(sort_j)) > unsigned(data_buf(sort_j + 1)) then
              data_buf(sort_j)     <= data_buf(sort_j + 1);
              data_buf(sort_j + 1) <= data_buf(sort_j);
              sort_swapped <= '1';
            end if;
            sort_j <= sort_j + 1;
          else
            sort_j <= 0;
            sort_i <= sort_i + 1;
            if sort_i >= buf_count - 2 or sort_swapped = '0' then
              null;
            else
              sort_swapped <= '0';
            end if;
          end if;
        end if;

        -- scan for longest consecutive run
        if state = SORT and next_state = SCAN then
          scan_idx <= 1;
          curr_len <= to_unsigned(1, 8);
          if buf_count > 0 then max_len <= to_unsigned(1, 8); else max_len <= (others => '0'); end if;
        elsif state = SCAN and scan_idx < buf_count then
          scan_idx <= scan_idx + 1;
          if data_buf(scan_idx) = data_buf(scan_idx - 1) then
            null;
          elsif unsigned(data_buf(scan_idx)) = unsigned(data_buf(scan_idx - 1)) + 1 then
            curr_len <= curr_len + 1;
            if curr_len + 1 > max_len then max_len <= curr_len + 1; end if;
          else
            curr_len <= to_unsigned(1, 8);
          end if;
        end if;
      end if;
    end if;
  end process;

  in_ready   <= in_ready_s;
  out_valid  <= out_valid_s;
  out_length <= (others => '0') when buf_count = 0 else std_logic_vector(max_len);
end architecture rtl;
