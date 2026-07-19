library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arp_detector is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(7 downto 0);
    in_sof : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_is_request : out std_logic;
    out_sender_ip : out std_logic_vector(31 downto 0);
    out_target_ip : out std_logic_vector(31 downto 0)
  );
end entity arp_detector;

architecture rtl of arp_detector is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant PARSE  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal byte_cnt   : integer range 0 to 31;
  signal operation     : std_logic_vector(15 downto 0);
  signal sender_ip_reg : std_logic_vector(31 downto 0);
  signal target_ip_reg : std_logic_vector(31 downto 0);
  signal in_ready_s, out_valid_s : std_logic;
begin
  in_ready_s  <= '1' when (state = IDLE or state = PARSE) else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, in_valid, in_ready_s, in_sof, byte_cnt, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if in_valid = '1' and in_ready_s = '1' and in_sof = '1' then next_state <= PARSE; end if;
      when PARSE =>
        if in_valid = '1' and in_ready_s = '1' and byte_cnt = 27 then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        byte_cnt      <= 0;
        operation     <= (others => '0');
        sender_ip_reg <= (others => '0');
        target_ip_reg <= (others => '0');
      else
        if in_valid = '1' and in_ready_s = '1' then
          if    byte_cnt = 6  then operation(15 downto 8)     <= in_data;
          elsif byte_cnt = 7  then operation(7 downto 0)      <= in_data;
          elsif byte_cnt = 14 then sender_ip_reg(31 downto 24) <= in_data;
          elsif byte_cnt = 15 then sender_ip_reg(23 downto 16) <= in_data;
          elsif byte_cnt = 16 then sender_ip_reg(15 downto 8)  <= in_data;
          elsif byte_cnt = 17 then sender_ip_reg(7 downto 0)   <= in_data;
          elsif byte_cnt = 24 then target_ip_reg(31 downto 24) <= in_data;
          elsif byte_cnt = 25 then target_ip_reg(23 downto 16) <= in_data;
          elsif byte_cnt = 26 then target_ip_reg(15 downto 8)  <= in_data;
          elsif byte_cnt = 27 then target_ip_reg(7 downto 0)   <= in_data;
          end if;
        end if;

        if state = IDLE and in_valid = '1' and in_ready_s = '1' and in_sof = '1' then
          byte_cnt <= 1;
        elsif state = PARSE and in_valid = '1' and in_ready_s = '1' then
          byte_cnt <= byte_cnt + 1;
        elsif state = OUTPUT and out_valid_s = '1' and out_ready = '1' then
          byte_cnt <= 0;
        end if;
      end if;
    end if;
  end process;

  in_ready       <= in_ready_s;
  out_valid      <= out_valid_s;
  out_is_request <= '1' when operation = x"0001" else '0';
  out_sender_ip  <= sender_ip_reg;
  out_target_ip  <= target_ip_reg;
end architecture rtl;
