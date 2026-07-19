library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity prime_check is
  generic (
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_num : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_is_prime : out std_logic
  );
end entity prime_check;

architecture rtl of prime_check is
  constant IDLE  : std_logic_vector(1 downto 0) := "00";
  constant CHECK : std_logic_vector(1 downto 0) := "01";
  constant DONE  : std_logic_vector(1 downto 0) := "10";

  signal state        : std_logic_vector(1 downto 0);
  signal in_ready_s   : std_logic;
  signal out_valid_s  : std_logic;
  signal is_prime_s   : std_logic;
  signal num          : unsigned(DATA_WIDTH-1 downto 0);
  signal divisor      : unsigned(DATA_WIDTH-1 downto 0);
  signal divisor_sq   : unsigned(2*DATA_WIDTH-1 downto 0);
begin
  process(clk)
    variable dnext : unsigned(DATA_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state       <= IDLE;
        in_ready_s  <= '1';
        out_valid_s <= '0';
        is_prime_s  <= '0';
        num         <= (others => '0');
        divisor     <= (others => '0');
        divisor_sq  <= (others => '0');
      else
        case state is
          when IDLE =>
            if in_valid = '1' and in_ready_s = '1' then
              in_ready_s <= '0';
              num        <= unsigned(in_num);
              if unsigned(in_num) <= 1 then
                state <= DONE; out_valid_s <= '1'; is_prime_s <= '0';
              elsif unsigned(in_num) <= 3 then
                state <= DONE; out_valid_s <= '1'; is_prime_s <= '1';
              elsif in_num(0) = '0' then
                state <= DONE; out_valid_s <= '1'; is_prime_s <= '0';
              else
                state      <= CHECK;
                divisor    <= to_unsigned(3, DATA_WIDTH);
                divisor_sq <= to_unsigned(9, 2*DATA_WIDTH);
              end if;
            end if;
          when CHECK =>
            if divisor_sq > num then
              state <= DONE; out_valid_s <= '1'; is_prime_s <= '1';
            elsif (num mod divisor) = 0 then
              state <= DONE; out_valid_s <= '1'; is_prime_s <= '0';
            else
              dnext      := divisor + 2;
              divisor    <= dnext;
              divisor_sq <= dnext * dnext;
            end if;
          when DONE =>
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0';
              in_ready_s  <= '1';
              state       <= IDLE;
            end if;
          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  in_ready     <= in_ready_s;
  out_valid    <= out_valid_s;
  out_is_prime <= is_prime_s;
end architecture rtl;
