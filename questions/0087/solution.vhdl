library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity trailing_zero is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    -- width is ceil(log2(DATA_WIDTH+1)); a byte covers every supported width
    out_count : out std_logic_vector(7 downto 0)
  );
end entity trailing_zero;

architecture rtl of trailing_zero is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant COUNT  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal data_reg   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal count_reg  : unsigned(7 downto 0);
  signal bit_idx    : integer range 0 to DATA_WIDTH;
  signal found_one  : std_logic;
  signal in_ready_s, out_valid_s : std_logic;
begin
  in_ready_s  <= '1' when state = IDLE   else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, in_valid, in_ready_s, found_one, bit_idx, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if in_valid = '1' and in_ready_s = '1' then next_state <= COUNT; end if;
      when COUNT =>
        if found_one = '1' or bit_idx >= DATA_WIDTH then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        data_reg  <= (others => '0');
        count_reg <= (others => '0');
        bit_idx   <= 0;
        found_one <= '0';
      elsif state = IDLE and next_state = COUNT then
        data_reg  <= in_data;
        count_reg <= (others => '0');
        bit_idx   <= 0;
        found_one <= '0';
      elsif state = COUNT and found_one = '0' and bit_idx < DATA_WIDTH then
        if data_reg(bit_idx) = '1' then
          found_one <= '1';
        else
          count_reg <= count_reg + 1;
          bit_idx   <= bit_idx + 1;
        end if;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_count <= std_logic_vector(count_reg);
end architecture rtl;
