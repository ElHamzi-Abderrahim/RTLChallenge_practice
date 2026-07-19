library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_copy_ctrl is
  generic (
    ADDR_WIDTH : integer := 8;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    src_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    dst_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    length : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    busy : out std_logic;
    done : out std_logic
  );
end entity mem_copy_ctrl;

architecture rtl of mem_copy_ctrl is
  component sram_rw_model is
    generic (ADDR_WIDTH : integer := 8; DATA_WIDTH : integer := 8);
    port (clk : in std_logic; req : in std_logic; wr : in std_logic;
          addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
          wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
          rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
          rvalid : out std_logic);
  end component;

  constant IDLE      : std_logic_vector(2 downto 0) := "000";
  constant READ      : std_logic_vector(2 downto 0) := "001";
  constant WAIT_READ : std_logic_vector(2 downto 0) := "010";
  constant WRITE     : std_logic_vector(2 downto 0) := "011";
  constant DONE_ST   : std_logic_vector(2 downto 0) := "100";

  signal state      : std_logic_vector(2 downto 0);
  signal mem_req    : std_logic;
  signal mem_wr     : std_logic;
  signal mem_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal mem_wdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rvalid : std_logic;
  signal src_addr_r : unsigned(ADDR_WIDTH-1 downto 0);
  signal dst_addr_r : unsigned(ADDR_WIDTH-1 downto 0);
  signal length_r   : unsigned(ADDR_WIDTH-1 downto 0);
  signal offset     : unsigned(ADDR_WIDTH-1 downto 0);
begin
  u_sram : sram_rw_model
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (clk => clk, req => mem_req, wr => mem_wr, addr => mem_addr,
              wdata => mem_wdata, rdata => mem_rdata, rvalid => mem_rvalid);

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state      <= IDLE;
        busy       <= '0';
        done       <= '0';
        mem_req    <= '0';
        mem_wr     <= '0';
        mem_addr   <= (others => '0');
        mem_wdata  <= (others => '0');
        src_addr_r <= (others => '0');
        dst_addr_r <= (others => '0');
        length_r   <= (others => '0');
        offset     <= (others => '0');
      else
        done    <= '0';
        mem_req <= '0';
        case state is
          when IDLE =>
            busy <= '0';
            if start = '1' then
              if unsigned(length) = 0 then
                done <= '1';
              else
                busy       <= '1';
                src_addr_r <= unsigned(src_addr);
                dst_addr_r <= unsigned(dst_addr);
                length_r   <= unsigned(length);
                offset     <= (others => '0');
                mem_req    <= '1'; mem_wr <= '0';
                mem_addr   <= src_addr;
                state      <= READ;
              end if;
            end if;
          when READ =>
            state <= WAIT_READ;
          when WAIT_READ =>
            if mem_rvalid = '1' then
              mem_req   <= '1'; mem_wr <= '1';
              mem_addr  <= std_logic_vector(dst_addr_r + offset);
              mem_wdata <= mem_rdata;
              state     <= WRITE;
            end if;
          when WRITE =>
            offset <= offset + 1;
            if offset + 1 >= length_r then
              state <= DONE_ST;
            else
              mem_req  <= '1'; mem_wr <= '0';
              mem_addr <= std_logic_vector(src_addr_r + offset + 1);
              state    <= READ;
            end if;
          when others =>
            done  <= '1';
            busy  <= '0';
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;
end architecture rtl;
