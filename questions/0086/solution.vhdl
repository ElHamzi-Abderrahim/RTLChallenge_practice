library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hamming_dist is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_a : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_b : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    -- width is ceil(log2(DATA_WIDTH+1)); VHDL has no $clog2 so a byte is used,
    -- which carries the value for every supported DATA_WIDTH
    out_dist : out std_logic_vector(7 downto 0)
  );
end entity hamming_dist;

architecture rtl of hamming_dist is
  constant IDLE    : std_logic_vector(1 downto 0) := "00";
  constant COMPUTE : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT  : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal xor_result : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal count      : unsigned(7 downto 0);
  signal bit_idx    : integer range 0 to DATA_WIDTH;
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

  process(state, in_valid, in_ready_s, bit_idx, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if in_valid = '1' and in_ready_s = '1' then next_state <= COMPUTE; end if;
      when COMPUTE =>
        if bit_idx >= DATA_WIDTH then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        xor_result <= (others => '0');
        count      <= (others => '0');
        bit_idx    <= 0;
      elsif state = IDLE and next_state = COMPUTE then
        xor_result <= in_a xor in_b;
        count      <= (others => '0');
        bit_idx    <= 0;
      elsif state = COMPUTE and bit_idx < DATA_WIDTH then
        if xor_result(bit_idx) = '1' then
          count <= count + 1;
        end if;
        bit_idx <= bit_idx + 1;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_dist  <= std_logic_vector(count);
end architecture rtl;
