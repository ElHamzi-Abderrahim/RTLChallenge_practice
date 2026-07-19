library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ipv4_checksum is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(15 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_checksum : out std_logic_vector(15 downto 0);
    out_valid_hdr : out std_logic
  );
end entity ipv4_checksum;

architecture rtl of ipv4_checksum is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant SUM_ST : std_logic_vector(1 downto 0) := "01";
  constant FOLD   : std_logic_vector(1 downto 0) := "10";
  constant OUTPUT : std_logic_vector(1 downto 0) := "11";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal sum_reg    : unsigned(31 downto 0);
  signal in_ready_s, out_valid_s : std_logic;
begin
  in_ready_s  <= '1' when state = SUM_ST else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, start, in_valid, in_ready_s, in_last, sum_reg, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start = '1' then next_state <= SUM_ST; end if;
      when SUM_ST =>
        if in_valid = '1' and in_ready_s = '1' and in_last = '1' then next_state <= FOLD; end if;
      when FOLD =>
        if sum_reg(31 downto 16) = 0 then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        sum_reg <= (others => '0');
      elsif state = IDLE and next_state = SUM_ST then
        sum_reg <= (others => '0');
      elsif state = SUM_ST and in_valid = '1' and in_ready_s = '1' then
        sum_reg <= sum_reg + unsigned(x"0000" & in_data);
      elsif state = FOLD and sum_reg(31 downto 16) /= 0 then
        sum_reg <= unsigned(x"0000" & std_logic_vector(sum_reg(15 downto 0)))
                 + unsigned(x"0000" & std_logic_vector(sum_reg(31 downto 16)));
      end if;
    end if;
  end process;

  in_ready      <= in_ready_s;
  out_valid     <= out_valid_s;
  out_checksum  <= std_logic_vector(not sum_reg(15 downto 0));
  out_valid_hdr <= '1' when sum_reg(15 downto 0) = x"FFFF" else '0';
end architecture rtl;
