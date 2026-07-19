library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity conv_1d is
  generic (
    DATA_WIDTH : integer := 8;
    KERNEL_SIZE : integer := 3;
    -- ceil(log2(KERNEL_SIZE)); VHDL has no $clog2, so it is carried as a generic
    KLOG2 : integer := 2
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    kernel_valid : in std_logic;
    kernel_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    kernel_ready : out std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH*2+KLOG2-1 downto 0);
    out_last : out std_logic
  );
end entity conv_1d;

architecture rtl of conv_1d is
  constant OUT_WIDTH : integer := DATA_WIDTH*2 + KLOG2;

  constant IDLE        : std_logic_vector(1 downto 0) := "00";
  constant LOAD_KERNEL : std_logic_vector(1 downto 0) := "01";
  constant RUN         : std_logic_vector(1 downto 0) := "10";
  constant EMIT        : std_logic_vector(1 downto 0) := "11";

  type k_arr is array(0 to KERNEL_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal kernel_arr : k_arr;
  signal window_arr : k_arr;

  signal state          : std_logic_vector(1 downto 0);
  signal kernel_ready_s : std_logic;
  signal in_ready_s     : std_logic;
  signal out_valid_s    : std_logic;
  signal k_idx          : integer range 0 to KERNEL_SIZE;
  signal w_count        : integer range 0 to KERNEL_SIZE;
  signal pending_last   : std_logic;
begin
  process(clk)
    variable k  : integer;
    variable j  : integer;
    variable cn : unsigned(OUT_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state <= IDLE; kernel_ready_s <= '0'; in_ready_s <= '0'; out_valid_s <= '0';
        out_data <= (others => '0'); out_last <= '0';
        k_idx <= 0; w_count <= 0; pending_last <= '0';
        k := 0;
        while k < KERNEL_SIZE loop
          kernel_arr(k) <= (others => '0');
          window_arr(k) <= (others => '0');
          k := k + 1;
        end loop;
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            out_last    <= '0';
            if start = '1' then
              state <= LOAD_KERNEL; kernel_ready_s <= '1';
              k_idx <= 0; w_count <= 0;
              k := 0;
              while k < KERNEL_SIZE loop
                window_arr(k) <= (others => '0');
                k := k + 1;
              end loop;
            end if;

          when LOAD_KERNEL =>
            if kernel_valid = '1' and kernel_ready_s = '1' then
              kernel_arr(k_idx) <= kernel_data;
              k_idx <= k_idx + 1;
              if k_idx = KERNEL_SIZE-1 then
                kernel_ready_s <= '0';
                state          <= RUN;
                in_ready_s     <= '1';
              end if;
            end if;

          when RUN =>
            if in_valid = '1' and in_ready_s = '1' then
              -- convolution over the window that exists after shifting in_data in
              cn := (others => '0');
              j := 0;
              while j < KERNEL_SIZE loop
                if j < KERNEL_SIZE-1 then
                  cn := cn + (unsigned(window_arr(j+1)) * unsigned(kernel_arr(j)));
                else
                  cn := cn + (unsigned(in_data) * unsigned(kernel_arr(j)));
                end if;
                j := j + 1;
              end loop;

              k := 0;
              while k < KERNEL_SIZE-1 loop
                window_arr(k) <= window_arr(k+1);
                k := k + 1;
              end loop;
              window_arr(KERNEL_SIZE-1) <= in_data;

              if w_count < KERNEL_SIZE then
                w_count <= w_count + 1;
              end if;

              if w_count >= KERNEL_SIZE-1 then
                in_ready_s   <= '0';
                state        <= EMIT;
                out_valid_s  <= '1';
                out_data     <= std_logic_vector(cn);
                out_last     <= in_last;
                pending_last <= in_last;
              elsif in_last = '1' then
                in_ready_s <= '0';
                state      <= IDLE;
              end if;
            end if;

          when others =>  -- EMIT
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0';
              out_last    <= '0';
              if pending_last = '1' then
                state <= IDLE;
              else
                state      <= RUN;
                in_ready_s <= '1';
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;

  kernel_ready <= kernel_ready_s;
  in_ready     <= in_ready_s;
  out_valid    <= out_valid_s;
end architecture rtl;
