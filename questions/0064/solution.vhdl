library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bubble_sort is
  generic (
    DATA_WIDTH : integer := 8;
    MAX_SIZE : integer := 8
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
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_last : out std_logic
  );
end entity bubble_sort;

architecture rtl of bubble_sort is
  constant IDLE   : std_logic_vector(2 downto 0) := "000";
  constant INPUT  : std_logic_vector(2 downto 0) := "001";
  constant SORT   : std_logic_vector(2 downto 0) := "010";
  constant OUTPUT : std_logic_vector(2 downto 0) := "011";

  type arr_t is array(0 to MAX_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal arr : arr_t;

  signal state       : std_logic_vector(2 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal count   : integer range 0 to MAX_SIZE;
  signal wr_idx  : integer range 0 to MAX_SIZE;
  signal rd_idx  : integer range 0 to MAX_SIZE;
  signal i_cnt   : integer range 0 to MAX_SIZE;
  signal j_cnt   : integer range 0 to MAX_SIZE;
  signal swapped : std_logic;
begin
  process(clk)
    variable k : integer;
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state       <= IDLE;
        in_ready_s  <= '0';
        out_valid_s <= '0';
        out_data    <= (others => '0');
        out_last    <= '0';
        count       <= 0;
        wr_idx      <= 0;
        rd_idx      <= 0;
        i_cnt       <= 0;
        j_cnt       <= 0;
        swapped     <= '0';
        k := 0;
        while k < MAX_SIZE loop
          arr(k) <= (others => '0');
          k := k + 1;
        end loop;
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            out_last    <= '0';
            if start = '1' then
              state      <= INPUT;
              in_ready_s <= '1';
              wr_idx     <= 0;
              count      <= 0;
            end if;

          when INPUT =>
            if in_valid = '1' and in_ready_s = '1' then
              arr(wr_idx) <= in_data;
              wr_idx <= wr_idx + 1;
              count  <= wr_idx + 1;
              if in_last = '1' or wr_idx = MAX_SIZE-1 then
                in_ready_s <= '0';
                state      <= SORT;
                i_cnt      <= 0;
                j_cnt      <= 0;
                swapped    <= '0';
                count      <= wr_idx + 1;
              end if;
            end if;

          when SORT =>
            if count <= 1 then
              state       <= OUTPUT;
              rd_idx      <= 0;
              out_valid_s <= '1';
              out_data    <= arr(0);
              out_last    <= '1';
            elsif j_cnt < count - 1 - i_cnt then
              if unsigned(arr(j_cnt)) > unsigned(arr(j_cnt + 1)) then
                arr(j_cnt)     <= arr(j_cnt + 1);
                arr(j_cnt + 1) <= arr(j_cnt);
                swapped <= '1';
              end if;
              j_cnt <= j_cnt + 1;
            else
              if swapped = '0' or i_cnt >= count - 2 then
                state       <= OUTPUT;
                rd_idx      <= 0;
                out_valid_s <= '1';
                out_data    <= arr(0);
                if count = 1 then out_last <= '1'; else out_last <= '0'; end if;
              else
                i_cnt   <= i_cnt + 1;
                j_cnt   <= 0;
                swapped <= '0';
              end if;
            end if;

          when others =>  -- OUTPUT
            if out_valid_s = '1' and out_ready = '1' then
              if rd_idx >= count - 1 then
                out_valid_s <= '0';
                out_last    <= '0';
                state       <= IDLE;
              else
                rd_idx   <= rd_idx + 1;
                out_data <= arr(rd_idx + 1);
                if rd_idx + 1 >= count - 1 then out_last <= '1'; else out_last <= '0'; end if;
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
