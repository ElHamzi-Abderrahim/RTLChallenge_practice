library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vlan_detector is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_ethertype : in std_logic_vector(15 downto 0);
    in_tci : in std_logic_vector(15 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_is_tagged : out std_logic;
    out_pcp : out std_logic_vector(2 downto 0);
    out_dei : out std_logic;
    out_vid : out std_logic_vector(11 downto 0)
  );
end entity vlan_detector;

architecture rtl of vlan_detector is
  constant VLAN_TPID : std_logic_vector(15 downto 0) := x"8100";
  constant ST_IDLE   : std_logic_vector(1 downto 0) := "00";
  constant ST_OUTPUT : std_logic_vector(1 downto 0) := "01";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal is_tagged_reg : std_logic;
  signal pcp_reg : std_logic_vector(2 downto 0);
  signal dei_reg : std_logic;
  signal vid_reg : std_logic_vector(11 downto 0);
  signal in_ready_s, out_valid_s : std_logic;
begin
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
        is_tagged_reg <= '0';
        pcp_reg <= (others => '0');
        dei_reg <= '0';
        vid_reg <= (others => '0');
      elsif state = ST_IDLE and next_state = ST_OUTPUT then
        if in_ethertype = VLAN_TPID then
          is_tagged_reg <= '1';
          pcp_reg <= in_tci(15 downto 13);
          dei_reg <= in_tci(12);
          vid_reg <= in_tci(11 downto 0);
        else
          is_tagged_reg <= '0';
          pcp_reg <= (others => '0');
          dei_reg <= '0';
          vid_reg <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  in_ready      <= in_ready_s;
  out_valid     <= out_valid_s;
  out_is_tagged <= is_tagged_reg;
  out_pcp       <= pcp_reg;
  out_dei       <= dei_reg;
  out_vid       <= vid_reg;
end architecture rtl;
