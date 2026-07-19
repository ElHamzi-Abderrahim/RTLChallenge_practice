library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pkt_len_validator is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(7 downto 0);
    in_last : in std_logic;
    hdr_total_len : in std_logic_vector(15 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_len_ok : out std_logic;
    out_actual_len : out std_logic_vector(15 downto 0)
  );
end entity pkt_len_validator;

architecture rtl of pkt_len_validator is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant COUNT  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal byte_count   : unsigned(15 downto 0);
  signal expected_len : unsigned(15 downto 0);
  signal in_ready_s, out_valid_s : std_logic;
  signal consume : std_logic;
begin
  in_ready_s  <= '1' when state = COUNT  else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';
  consume     <= '1' when (state = COUNT and in_valid = '1') else '0';

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
        if start = '1' then next_state <= COUNT; end if;
      when COUNT =>
        if consume = '1' and in_last = '1' then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        byte_count   <= (others => '0');
        expected_len <= (others => '0');
      elsif state = IDLE and next_state = COUNT then
        byte_count   <= (others => '0');
        expected_len <= unsigned(hdr_total_len);
      elsif consume = '1' then
        byte_count <= byte_count + 1;
      end if;
    end if;
  end process;

  in_ready       <= in_ready_s;
  out_valid      <= out_valid_s;
  out_len_ok     <= '1' when byte_count = expected_len else '0';
  out_actual_len <= std_logic_vector(byte_count);
end architecture rtl;
