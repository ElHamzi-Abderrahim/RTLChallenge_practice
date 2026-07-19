library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fib_gen is
  generic (
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    out_ready : in std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_index : out std_logic_vector(7 downto 0)
  );
end entity fib_gen;

architecture rtl of fib_gen is
  signal out_valid_s : std_logic;
  signal out_index_s : unsigned(7 downto 0);
  signal fib_prev    : unsigned(DATA_WIDTH-1 downto 0);
  signal fib_curr    : unsigned(DATA_WIDTH-1 downto 0);
  signal running     : std_logic;
  signal handshake   : std_logic;
begin
  handshake <= out_valid_s and out_ready;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        out_valid_s <= '0';
        out_data    <= (others => '0');
        out_index_s <= (others => '0');
        fib_prev    <= (others => '0');
        fib_curr    <= to_unsigned(1, DATA_WIDTH);
        running     <= '0';
      else
        if start = '1' then
          running     <= '1';
          out_valid_s <= '1';
          out_data    <= (others => '0');
          out_index_s <= (others => '0');
          fib_prev    <= (others => '0');
          fib_curr    <= to_unsigned(1, DATA_WIDTH);
        elsif running = '1' and handshake = '1' then
          out_index_s <= out_index_s + 1;
          if out_index_s = 0 then
            out_data <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
          else
            out_data <= std_logic_vector(fib_prev + fib_curr);
            fib_prev <= fib_curr;
            fib_curr <= fib_prev + fib_curr;
          end if;
        end if;
      end if;
    end if;
  end process;

  out_valid <= out_valid_s;
  out_index <= std_logic_vector(out_index_s);
end architecture rtl;
