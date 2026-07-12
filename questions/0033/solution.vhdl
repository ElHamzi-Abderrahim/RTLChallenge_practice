library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity async_fifo is
  generic (
    DATA_WIDTH : integer := 8;
    FIFO_DEPTH : integer := 16
  );
  port (
    wr_clk : in std_logic;
    wr_rst_n : in std_logic;
    wr_en : in std_logic;
    wr_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    wr_full : out std_logic;
    rd_clk : in std_logic;
    rd_rst_n : in std_logic;
    rd_en : in std_logic;
    rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    rd_empty : out std_logic
  );
end entity async_fifo;

architecture rtl of async_fifo is
  constant DEPTH2 : integer := 2 * FIFO_DEPTH;   -- pointers count 0..2*DEPTH-1

  type mem_t is array(0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal memory : mem_t;

  signal wr_bin      : integer range 0 to DEPTH2-1;
  signal rd_bin      : integer range 0 to DEPTH2-1;
  signal wr_bin_next : integer range 0 to DEPTH2-1;
  signal rd_bin_next : integer range 0 to DEPTH2-1;
  signal wr_bin_sync : integer range 0 to DEPTH2-1;
  signal rd_bin_sync : integer range 0 to DEPTH2-1;

  signal wr_gray     : std_logic_vector(5 downto 0);   -- fixed gray width 6
  signal rd_gray     : std_logic_vector(5 downto 0);
  signal wr_gray_s1  : std_logic_vector(5 downto 0);
  signal wr_gray_s2  : std_logic_vector(5 downto 0);
  signal rd_gray_s1  : std_logic_vector(5 downto 0);
  signal rd_gray_s2  : std_logic_vector(5 downto 0);

  signal full_s   : std_logic;
  signal empty_s  : std_logic;
  signal wr_push  : std_logic;
  signal rd_pop   : std_logic;
  signal wr_addr  : integer range 0 to FIFO_DEPTH-1;
  signal rd_addr  : integer range 0 to FIFO_DEPTH-1;
begin
  -- Gray codes from the registered binary pointers
  wr_gray <= std_logic_vector(to_unsigned(wr_bin, 6) xor shift_right(to_unsigned(wr_bin, 6), 1));
  rd_gray <= std_logic_vector(to_unsigned(rd_bin, 6) xor shift_right(to_unsigned(rd_bin, 6), 1));

  -- Gray-to-binary of the synchronized pointers (continuous)
  rd_bin_sync <= to_integer(unsigned(
      rd_gray_s2(5)
    & (rd_gray_s2(5) xor rd_gray_s2(4))
    & (rd_gray_s2(5) xor rd_gray_s2(4) xor rd_gray_s2(3))
    & (rd_gray_s2(5) xor rd_gray_s2(4) xor rd_gray_s2(3) xor rd_gray_s2(2))
    & (rd_gray_s2(5) xor rd_gray_s2(4) xor rd_gray_s2(3) xor rd_gray_s2(2) xor rd_gray_s2(1))
    & (rd_gray_s2(5) xor rd_gray_s2(4) xor rd_gray_s2(3) xor rd_gray_s2(2) xor rd_gray_s2(1) xor rd_gray_s2(0))));

  wr_bin_sync <= to_integer(unsigned(
      wr_gray_s2(5)
    & (wr_gray_s2(5) xor wr_gray_s2(4))
    & (wr_gray_s2(5) xor wr_gray_s2(4) xor wr_gray_s2(3))
    & (wr_gray_s2(5) xor wr_gray_s2(4) xor wr_gray_s2(3) xor wr_gray_s2(2))
    & (wr_gray_s2(5) xor wr_gray_s2(4) xor wr_gray_s2(3) xor wr_gray_s2(2) xor wr_gray_s2(1))
    & (wr_gray_s2(5) xor wr_gray_s2(4) xor wr_gray_s2(3) xor wr_gray_s2(2) xor wr_gray_s2(1) xor wr_gray_s2(0))));

  full_s  <= '1' when ((wr_bin - rd_bin_sync + DEPTH2) mod DEPTH2) = FIFO_DEPTH else '0';
  empty_s <= '1' when rd_bin = wr_bin_sync else '0';

  wr_push <= wr_en and (not full_s);
  rd_pop  <= rd_en and (not empty_s);

  wr_addr <= wr_bin mod FIFO_DEPTH;
  rd_addr <= rd_bin mod FIFO_DEPTH;

  -- Combinational next-state pointers (immune to enable-vs-clock race)
  process(wr_push, wr_bin)
  begin
    if wr_push = '1' then
      if wr_bin = DEPTH2-1 then
        wr_bin_next <= 0;
      else
        wr_bin_next <= wr_bin + 1;
      end if;
    else
      wr_bin_next <= wr_bin;
    end if;
  end process;

  process(rd_pop, rd_bin)
  begin
    if rd_pop = '1' then
      if rd_bin = DEPTH2-1 then
        rd_bin_next <= 0;
      else
        rd_bin_next <= rd_bin + 1;
      end if;
    else
      rd_bin_next <= rd_bin;
    end if;
  end process;

  -- Write clock domain
  process(wr_clk)
  begin
    if rising_edge(wr_clk) then
      if wr_rst_n = '0' then
        wr_bin     <= 0;
        rd_gray_s1 <= (others => '0');
        rd_gray_s2 <= (others => '0');
      else
        rd_gray_s1 <= rd_gray;
        rd_gray_s2 <= rd_gray_s1;
        wr_bin     <= wr_bin_next;
        if wr_push = '1' then
          memory(wr_addr) <= wr_data;
        end if;
      end if;
    end if;
  end process;

  -- Read clock domain
  process(rd_clk)
  begin
    if rising_edge(rd_clk) then
      if rd_rst_n = '0' then
        rd_bin     <= 0;
        wr_gray_s1 <= (others => '0');
        wr_gray_s2 <= (others => '0');
      else
        wr_gray_s1 <= wr_gray;
        wr_gray_s2 <= wr_gray_s1;
        rd_bin     <= rd_bin_next;
      end if;
    end if;
  end process;

  rd_data  <= memory(rd_addr);
  wr_full  <= full_s;
  rd_empty <= empty_s;
end architecture rtl;
