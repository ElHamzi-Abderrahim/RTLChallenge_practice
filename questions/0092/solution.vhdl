library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_filter is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    cfg_mac : in std_logic_vector(47 downto 0);
    cfg_promisc : in std_logic;
    in_valid : in std_logic;
    in_dst_mac : in std_logic_vector(47 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_accept : out std_logic;
    out_reason : out std_logic_vector(2 downto 0)
  );
end entity mac_filter;

architecture rtl of mac_filter is
  constant REASON_REJECT    : std_logic_vector(2 downto 0) := "000";
  constant REASON_UNICAST   : std_logic_vector(2 downto 0) := "001";
  constant REASON_BROADCAST : std_logic_vector(2 downto 0) := "010";
  constant REASON_MULTICAST : std_logic_vector(2 downto 0) := "011";
  constant REASON_PROMISC   : std_logic_vector(2 downto 0) := "100";

  constant ST_IDLE   : std_logic := '0';
  constant ST_OUTPUT : std_logic := '1';

  signal state      : std_logic;
  signal next_state : std_logic;
  signal accept_reg : std_logic;
  signal reason_reg : std_logic_vector(2 downto 0);
  signal is_broadcast, is_multicast, is_unicast_match : std_logic;
  signal in_ready_s, out_valid_s : std_logic;
begin
  is_broadcast     <= '1' when in_dst_mac = x"FFFFFFFFFFFF" else '0';
  is_multicast     <= in_dst_mac(40);
  is_unicast_match <= '1' when in_dst_mac = cfg_mac else '0';

  in_ready_s  <= '1' when state = ST_IDLE   else '0';
  out_valid_s <= '1' when state = ST_OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= ST_IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, in_valid, in_ready_s, out_valid_s, out_ready)
  begin
    next_state <= state;
    if state = ST_IDLE then
      if in_valid = '1' and in_ready_s = '1' then next_state <= ST_OUTPUT; end if;
    else
      if out_valid_s = '1' and out_ready = '1' then next_state <= ST_IDLE; end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        accept_reg <= '0';
        reason_reg <= REASON_REJECT;
      elsif state = ST_IDLE and in_valid = '1' and in_ready_s = '1' then
        if cfg_promisc = '1' then
          accept_reg <= '1'; reason_reg <= REASON_PROMISC;
        elsif is_broadcast = '1' then
          accept_reg <= '1'; reason_reg <= REASON_BROADCAST;
        elsif is_multicast = '1' then
          accept_reg <= '1'; reason_reg <= REASON_MULTICAST;
        elsif is_unicast_match = '1' then
          accept_reg <= '1'; reason_reg <= REASON_UNICAST;
        else
          accept_reg <= '0'; reason_reg <= REASON_REJECT;
        end if;
      end if;
    end if;
  end process;

  in_ready   <= in_ready_s;
  out_valid  <= out_valid_s;
  out_accept <= accept_reg;
  out_reason <= reason_reg;
end architecture rtl;
