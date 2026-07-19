library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity eth_header_parser is
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(7 downto 0);
    in_sof : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_dst_mac : out std_logic_vector(47 downto 0);
    out_src_mac : out std_logic_vector(47 downto 0);
    out_ethertype : out std_logic_vector(15 downto 0)
  );
end entity eth_header_parser;

architecture rtl of eth_header_parser is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant PARSE  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal byte_cnt   : integer range 0 to 15;
  signal dst_mac_reg   : std_logic_vector(47 downto 0);
  signal src_mac_reg   : std_logic_vector(47 downto 0);
  signal ethertype_reg : std_logic_vector(15 downto 0);
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
        if in_valid = '1' and in_ready_s = '1' and byte_cnt = 13 then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        byte_cnt      <= 0;
        dst_mac_reg   <= (others => '0');
        src_mac_reg   <= (others => '0');
        ethertype_reg <= (others => '0');
      else
        -- field capture
        if in_valid = '1' and in_ready_s = '1' then
          if in_sof = '1' or state = PARSE then
            if    byte_cnt = 0  then dst_mac_reg(47 downto 40) <= in_data;
            elsif byte_cnt = 1  then dst_mac_reg(39 downto 32) <= in_data;
            elsif byte_cnt = 2  then dst_mac_reg(31 downto 24) <= in_data;
            elsif byte_cnt = 3  then dst_mac_reg(23 downto 16) <= in_data;
            elsif byte_cnt = 4  then dst_mac_reg(15 downto 8)  <= in_data;
            elsif byte_cnt = 5  then dst_mac_reg(7 downto 0)   <= in_data;
            elsif byte_cnt = 6  then src_mac_reg(47 downto 40) <= in_data;
            elsif byte_cnt = 7  then src_mac_reg(39 downto 32) <= in_data;
            elsif byte_cnt = 8  then src_mac_reg(31 downto 24) <= in_data;
            elsif byte_cnt = 9  then src_mac_reg(23 downto 16) <= in_data;
            elsif byte_cnt = 10 then src_mac_reg(15 downto 8)  <= in_data;
            elsif byte_cnt = 11 then src_mac_reg(7 downto 0)   <= in_data;
            elsif byte_cnt = 12 then ethertype_reg(15 downto 8) <= in_data;
            elsif byte_cnt = 13 then ethertype_reg(7 downto 0)  <= in_data;
            end if;
          end if;
        end if;

        -- byte counter
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

  in_ready      <= in_ready_s;
  out_valid     <= out_valid_s;
  out_dst_mac   <= dst_mac_reg;
  out_src_mac   <= src_mac_reg;
  out_ethertype <= ethertype_reg;
end architecture rtl;
