library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bitonic_detect is
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
    out_is_bitonic : out std_logic;
    out_peak_idx : out std_logic_vector(7 downto 0)
  );
end entity bitonic_detect;

architecture rtl of bitonic_detect is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant INPUT  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  constant PHASE_INIT : std_logic_vector(1 downto 0) := "00";
  constant PHASE_INC  : std_logic_vector(1 downto 0) := "01";
  constant PHASE_DEC  : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal phase      : std_logic_vector(1 downto 0);
  signal prev_val   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal curr_idx   : unsigned(7 downto 0);
  signal peak_idx   : unsigned(7 downto 0);
  signal is_bitonic : std_logic;
  signal first_elem : std_logic;
  signal in_ready_s, out_valid_s : std_logic;
  signal consume : std_logic;
  signal data_c  : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
  in_ready_s  <= '1' when state = INPUT  else '0';
  -- computed during the cycle so the capture cannot race the falling in_valid
  consume     <= '1' when (state = INPUT and in_valid = '1') else '0';
  data_c      <= in_data;
  out_valid_s <= '1' when state = OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, start, in_valid, in_ready_s, in_last, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= INPUT; end if;
      when INPUT =>
        if in_valid = '1' and in_last = '1' then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' or start = '1' then
        prev_val   <= (others => '0');
        curr_idx   <= (others => '0');
        peak_idx   <= (others => '0');
        phase      <= PHASE_INIT;
        is_bitonic <= '1';
        first_elem <= '1';
      elsif consume = '1' then
        prev_val <= data_c;
        curr_idx <= curr_idx + 1;
        if first_elem = '1' then
          first_elem <= '0';
          peak_idx   <= (others => '0');
        else
          if unsigned(data_c) > unsigned(prev_val) then
            case phase is
              when PHASE_INIT =>
                phase    <= PHASE_INC;
                peak_idx <= curr_idx;
              when PHASE_INC =>
                peak_idx <= curr_idx;
              when others =>
                is_bitonic <= '0';
            end case;
          elsif unsigned(data_c) < unsigned(prev_val) then
            case phase is
              when PHASE_INIT =>
                phase <= PHASE_DEC;
              when PHASE_INC =>
                phase <= PHASE_DEC;
              when others =>
                null;
            end case;
          end if;
        end if;
      end if;
    end if;
  end process;

  in_ready       <= in_ready_s;
  out_valid      <= out_valid_s;
  out_is_bitonic <= is_bitonic;
  out_peak_idx   <= std_logic_vector(peak_idx);
end architecture rtl;
