library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity peak_detect is
  generic (
    DATA_WIDTH : integer := 8
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
    out_is_peak : out std_logic;
    out_value : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_index : out std_logic_vector(7 downto 0)
  );
end entity peak_detect;

architecture rtl of peak_detect is
  constant IDLE  : std_logic_vector(1 downto 0) := "00";
  constant INPUT : std_logic_vector(1 downto 0) := "01";
  constant EMIT  : std_logic_vector(1 downto 0) := "10";

  signal state        : std_logic_vector(1 downto 0);
  signal in_ready_s   : std_logic;
  signal out_valid_s  : std_logic;
  signal val_prev     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal val_curr     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal val_next     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal idx_curr     : unsigned(7 downto 0);
  signal count        : unsigned(1 downto 0);
  signal pending_last : std_logic;
  signal in_hs, out_hs : std_logic;
begin
  in_hs  <= in_valid and in_ready_s;
  out_hs <= out_valid_s and out_ready;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state <= IDLE; in_ready_s <= '0'; out_valid_s <= '0';
        out_is_peak <= '0'; out_value <= (others => '0'); out_index <= (others => '0');
        val_prev <= (others => '0'); val_curr <= (others => '0'); val_next <= (others => '0');
        idx_curr <= (others => '0'); count <= (others => '0'); pending_last <= '0';
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            if start = '1' then
              state <= INPUT; in_ready_s <= '1';
              count <= (others => '0'); idx_curr <= (others => '0'); pending_last <= '0';
            end if;

          when INPUT =>
            if in_hs = '1' then
              if count = 0 then
                val_prev <= in_data;
                count    <= to_unsigned(1, 2);
                if in_last = '1' then
                  in_ready_s <= '0';
                  state      <= IDLE;
                end if;
              elsif count = 1 then
                val_curr <= in_data;
                idx_curr <= to_unsigned(1, 8);
                count    <= to_unsigned(2, 2);
                if in_last = '1' then
                  in_ready_s <= '0';
                  state      <= IDLE;
                end if;
              else
                val_next   <= in_data;
                state      <= EMIT;
                in_ready_s <= '0';
                out_valid_s <= '1';
                out_value   <= val_curr;
                out_index   <= std_logic_vector(idx_curr);
                if unsigned(val_curr) > unsigned(val_prev) and unsigned(val_curr) > unsigned(in_data) then
                  out_is_peak <= '1';
                else
                  out_is_peak <= '0';
                end if;
                pending_last <= in_last;
              end if;
            end if;

          when others =>  -- EMIT
            if out_hs = '1' then
              out_valid_s <= '0';
              val_prev <= val_curr;
              val_curr <= val_next;
              idx_curr <= idx_curr + 1;
              if pending_last = '1' then
                state <= IDLE;
              else
                state      <= INPUT;
                in_ready_s <= '1';
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
