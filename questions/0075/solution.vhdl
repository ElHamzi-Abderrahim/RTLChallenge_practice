library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rle_encoder is
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
    out_value : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_count : out std_logic_vector(7 downto 0);
    out_last : out std_logic
  );
end entity rle_encoder;

architecture rtl of rle_encoder is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant ENCODE : std_logic_vector(1 downto 0) := "01";
  constant EMIT   : std_logic_vector(1 downto 0) := "10";

  signal state         : std_logic_vector(1 downto 0);
  signal in_ready_s    : std_logic;
  signal out_valid_s   : std_logic;
  signal curr_value    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal curr_count    : unsigned(7 downto 0);
  signal is_last_run   : std_logic;
  signal first_value   : std_logic;
  signal final_pending : std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state <= IDLE; in_ready_s <= '0'; out_valid_s <= '0';
        out_value <= (others => '0'); out_count <= (others => '0'); out_last <= '0';
        curr_value <= (others => '0'); curr_count <= (others => '0');
        is_last_run <= '0'; first_value <= '1'; final_pending <= '0';
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            out_last    <= '0';
            if start = '1' then
              state <= ENCODE; in_ready_s <= '1'; curr_count <= (others => '0');
              first_value <= '1'; is_last_run <= '0'; final_pending <= '0';
            end if;

          when ENCODE =>
            if in_valid = '1' and in_ready_s = '1' then
              if first_value = '1' then
                curr_value  <= in_data;
                curr_count  <= to_unsigned(1, 8);
                first_value <= '0';
                if in_last = '1' then
                  state <= EMIT; in_ready_s <= '0'; out_valid_s <= '1';
                  out_value <= in_data; out_count <= std_logic_vector(to_unsigned(1, 8));
                  out_last <= '1'; is_last_run <= '1';
                end if;
              elsif in_data = curr_value and curr_count < 255 then
                curr_count <= curr_count + 1;
                if in_last = '1' then
                  state <= EMIT; in_ready_s <= '0'; out_valid_s <= '1';
                  out_value <= curr_value; out_count <= std_logic_vector(curr_count + 1);
                  out_last <= '1'; is_last_run <= '1';
                end if;
              else
                state <= EMIT; in_ready_s <= '0'; out_valid_s <= '1';
                out_value <= curr_value; out_count <= std_logic_vector(curr_count);
                out_last <= '0';
                curr_value    <= in_data;
                curr_count    <= to_unsigned(1, 8);
                is_last_run   <= '0';
                final_pending <= in_last;
              end if;
            end if;

          when others =>  -- EMIT
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0';
              out_last    <= '0';
              if is_last_run = '1' then
                state <= IDLE;
              elsif final_pending = '1' then
                out_valid_s   <= '1';
                out_value     <= curr_value;
                out_count     <= std_logic_vector(curr_count);
                out_last      <= '1';
                is_last_run   <= '1';
                final_pending <= '0';
              else
                state      <= ENCODE;
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
