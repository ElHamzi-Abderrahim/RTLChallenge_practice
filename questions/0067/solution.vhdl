library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity moving_max is
  generic (
    DATA_WIDTH : integer := 8;
    WINDOW_SIZE : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_max : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity moving_max;

architecture rtl of moving_max is
  type buf_t is array(0 to WINDOW_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal buffer_arr : buf_t;
  signal wr_ptr : integer range 0 to WINDOW_SIZE-1;
  signal count  : integer range 0 to WINDOW_SIZE;
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal in_hs  : std_logic;
  signal out_hs : std_logic;
begin
  in_hs  <= in_valid and in_ready_s;
  out_hs <= out_valid_s and out_ready;

  process(clk)
    variable k  : integer;
    variable nm : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable vi : std_logic_vector(DATA_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        wr_ptr      <= 0;
        count       <= 0;
        in_ready_s  <= '1';
        out_valid_s <= '0';
        out_max     <= (others => '0');
        k := 0;
        while k < WINDOW_SIZE loop
          buffer_arr(k) <= (others => '0');
          k := k + 1;
        end loop;
      elsif start = '1' then
        wr_ptr      <= 0;
        count       <= 0;
        in_ready_s  <= '1';
        out_valid_s <= '0';
        k := 0;
        while k < WINDOW_SIZE loop
          buffer_arr(k) <= (others => '0');
          k := k + 1;
        end loop;
      else
        if out_hs = '1' then
          out_valid_s <= '0';
        end if;

        if in_hs = '1' then
          -- max over window after writing in_data to slot wr_ptr
          nm := (others => '0');
          k := 0;
          while k < WINDOW_SIZE loop
            if k = wr_ptr then vi := in_data; else vi := buffer_arr(k); end if;
            if k <= count then
              if unsigned(vi) > unsigned(nm) then nm := vi; end if;
            end if;
            k := k + 1;
          end loop;

          buffer_arr(wr_ptr) <= in_data;
          if wr_ptr = WINDOW_SIZE-1 then wr_ptr <= 0; else wr_ptr <= wr_ptr + 1; end if;
          if count < WINDOW_SIZE then count <= count + 1; end if;

          out_max     <= nm;
          out_valid_s <= '1';
          in_ready_s  <= '0';
        elsif out_valid_s = '0' or out_hs = '1' then
          in_ready_s <= '1';
        end if;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
