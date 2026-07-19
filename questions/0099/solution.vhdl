library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity max_pool is
  generic (
    DATA_WIDTH : integer := 8;
    POOL_SIZE : integer := 4
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
    out_max : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity max_pool;

architecture rtl of max_pool is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant POOL   : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal max_reg    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal in_ready_s, out_valid_s, consume : std_logic;
begin
  in_ready_s  <= '1' when state = POOL   else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';
  consume     <= '1' when (state = POOL and in_valid = '1') else '0';

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
        if start = '1' then next_state <= POOL; end if;
      when POOL =>
        if consume = '1' and in_last = '1' then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        max_reg <= (others => '0');
      elsif state = IDLE and next_state = POOL then
        max_reg <= (others => '0');
      elsif consume = '1' then
        if unsigned(in_data) > unsigned(max_reg) then
          max_reg <= in_data;
        end if;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_max   <= max_reg;
end architecture rtl;
