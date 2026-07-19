library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity palindrome_check is
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
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_is_palindrome : out std_logic
  );
end entity palindrome_check;

architecture rtl of palindrome_check is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant INPUT  : std_logic_vector(1 downto 0) := "01";
  constant CHECK  : std_logic_vector(1 downto 0) := "10";
  constant OUTPUT : std_logic_vector(1 downto 0) := "11";

  type buf_t is array(0 to MAX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal buffer_arr : buf_t;

  signal state         : std_logic_vector(1 downto 0);
  signal in_ready_s    : std_logic;
  signal out_valid_s   : std_logic;
  signal is_palindrome : std_logic;
  signal count     : integer range 0 to MAX_SIZE;
  signal wr_idx    : integer range 0 to MAX_SIZE;
  signal check_idx : integer range 0 to MAX_SIZE;
begin
  process(clk)
    variable k : integer;
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state             <= IDLE;
        in_ready_s        <= '0';
        out_valid_s       <= '0';
        out_is_palindrome <= '0';
        count             <= 0;
        wr_idx            <= 0;
        check_idx         <= 0;
        is_palindrome     <= '1';
        k := 0;
        while k < MAX_SIZE loop
          buffer_arr(k) <= (others => '0');
          k := k + 1;
        end loop;
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            if start = '1' then
              state      <= INPUT;
              in_ready_s <= '1';
              wr_idx     <= 0;
              count      <= 0;
            end if;
          when INPUT =>
            if in_valid = '1' and in_ready_s = '1' then
              buffer_arr(wr_idx) <= in_data;
              wr_idx <= wr_idx + 1;
              count  <= wr_idx + 1;
              if in_last = '1' or wr_idx = MAX_SIZE-1 then
                in_ready_s    <= '0';
                state         <= CHECK;
                count         <= wr_idx + 1;
                check_idx     <= 0;
                is_palindrome <= '1';
              end if;
            end if;
          when CHECK =>
            if check_idx < count/2 then
              if buffer_arr(check_idx) /= buffer_arr(count-1-check_idx) then
                is_palindrome <= '0';
              end if;
              check_idx <= check_idx + 1;
            else
              state             <= OUTPUT;
              out_valid_s       <= '1';
              out_is_palindrome <= is_palindrome;
            end if;
          when others =>  -- OUTPUT
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0';
              state       <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
