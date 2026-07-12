library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_fifo is
  generic (
    DEPTH : integer := 4;
    DATA_W : integer := 1
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    push_i : in std_logic;
    push_data_i : in std_logic_vector(DATA_W-1 downto 0);
    pop_i : in std_logic;
    pop_data_o : out std_logic_vector(DATA_W-1 downto 0);
    full_o : out std_logic;
    empty_o : out std_logic
  );
end entity sync_fifo;

architecture rtl of sync_fifo is
  type mem_t is array(0 to DEPTH-1) of std_logic_vector(DATA_W-1 downto 0);
  signal fifo_mem : mem_t;
  signal rd_ptr   : integer range 0 to DEPTH-1;
  signal wr_ptr   : integer range 0 to DEPTH-1;
  signal count    : integer range 0 to DEPTH;
  signal full_s   : std_logic;
  signal empty_s  : std_logic;
  signal push_ok  : std_logic;
  signal pop_ok   : std_logic;
begin
  full_s  <= '1' when count = DEPTH else '0';
  empty_s <= '1' when count = 0     else '0';
  push_ok <= push_i and (not full_s);
  pop_ok  <= pop_i  and (not empty_s);

  process(clk, reset)
  begin
    if reset = '1' then
      rd_ptr <= 0;
      wr_ptr <= 0;
      count  <= 0;
    elsif rising_edge(clk) then
      if push_ok = '1' then
        fifo_mem(wr_ptr) <= push_data_i;
        if wr_ptr = DEPTH-1 then
          wr_ptr <= 0;
        else
          wr_ptr <= wr_ptr + 1;
        end if;
      end if;

      if pop_ok = '1' then
        if rd_ptr = DEPTH-1 then
          rd_ptr <= 0;
        else
          rd_ptr <= rd_ptr + 1;
        end if;
      end if;

      if push_ok = '1' and pop_ok = '0' then
        count <= count + 1;
      elsif push_ok = '0' and pop_ok = '1' then
        count <= count - 1;
      end if;
    end if;
  end process;

  pop_data_o <= fifo_mem(rd_ptr);
  full_o     <= full_s;
  empty_o    <= empty_s;
end architecture rtl;
