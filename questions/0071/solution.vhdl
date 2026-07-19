library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity two_sum is
  generic (
    DATA_WIDTH : integer := 8;
    MAX_SIZE : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    target : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_found : out std_logic;
    out_idx1 : out std_logic_vector(7 downto 0);
    out_idx2 : out std_logic_vector(7 downto 0)
  );
end entity two_sum;

architecture rtl of two_sum is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant INPUT  : std_logic_vector(1 downto 0) := "01";
  constant SEARCH : std_logic_vector(1 downto 0) := "10";
  constant OUTPUT : std_logic_vector(1 downto 0) := "11";

  type arr_t is array(0 to MAX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal arr : arr_t;

  signal state       : std_logic_vector(1 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal target_reg  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal count  : integer range 0 to MAX_SIZE;
  signal wr_idx : integer range 0 to MAX_SIZE;
  signal i_idx  : integer range 0 to MAX_SIZE;
  signal j_idx  : integer range 0 to MAX_SIZE;
begin
  process(clk)
    variable k : integer;
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state       <= IDLE;
        in_ready_s  <= '0';
        out_valid_s <= '0';
        out_found   <= '0';
        out_idx1    <= (others => '0');
        out_idx2    <= (others => '0');
        count       <= 0; wr_idx <= 0; i_idx <= 0; j_idx <= 0;
        target_reg  <= (others => '0');
        k := 0;
        while k < MAX_SIZE loop arr(k) <= (others => '0'); k := k + 1; end loop;
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            if start = '1' then
              state <= INPUT; in_ready_s <= '1'; wr_idx <= 0; count <= 0;
              target_reg <= target;
            end if;
          when INPUT =>
            if in_valid = '1' and in_ready_s = '1' then
              arr(wr_idx) <= in_data;
              wr_idx <= wr_idx + 1;
              count  <= wr_idx + 1;
              if in_last = '1' or wr_idx = MAX_SIZE-1 then
                in_ready_s <= '0'; state <= SEARCH; count <= wr_idx + 1;
                i_idx <= 0; j_idx <= 1;
              end if;
            end if;
          when SEARCH =>
            if count < 2 then
              state <= OUTPUT; out_valid_s <= '1'; out_found <= '0';
            elsif unsigned(arr(i_idx)) + unsigned(arr(j_idx)) = unsigned(target_reg) then
              state <= OUTPUT; out_valid_s <= '1'; out_found <= '1';
              out_idx1 <= std_logic_vector(to_unsigned(i_idx, 8));
              out_idx2 <= std_logic_vector(to_unsigned(j_idx, 8));
            else
              if j_idx < count - 1 then
                j_idx <= j_idx + 1;
              else
                if i_idx < count - 2 then
                  i_idx <= i_idx + 1;
                  j_idx <= i_idx + 2;
                else
                  state <= OUTPUT; out_valid_s <= '1'; out_found <= '0';
                end if;
              end if;
            end if;
          when others =>  -- OUTPUT
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0'; state <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
