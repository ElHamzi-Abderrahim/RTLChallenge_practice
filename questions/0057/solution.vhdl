library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity histogram_calc is
  generic (
    BIN_ADDR_WIDTH : integer := 4;
    COUNT_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    clear : in std_logic;
    data_valid : in std_logic;
    data_in : in std_logic_vector(BIN_ADDR_WIDTH-1 downto 0);
    read_req : in std_logic;
    read_addr : in std_logic_vector(BIN_ADDR_WIDTH-1 downto 0);
    ready : out std_logic;
    read_valid : out std_logic;
    read_data : out std_logic_vector(COUNT_WIDTH-1 downto 0)
  );
end entity histogram_calc;

architecture rtl of histogram_calc is
  component sram_rw_model is
    generic (ADDR_WIDTH : integer := 4; DATA_WIDTH : integer := 8);
    port (clk : in std_logic; req : in std_logic; wr : in std_logic;
          addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
          wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
          rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
          rvalid : out std_logic);
  end component;

  constant NUM_BINS  : integer := 2**BIN_ADDR_WIDTH;

  constant IDLE      : std_logic_vector(2 downto 0) := "000";
  constant CLEARING  : std_logic_vector(2 downto 0) := "001";
  constant INC_READ  : std_logic_vector(2 downto 0) := "010";
  constant INC_WAIT  : std_logic_vector(2 downto 0) := "011";
  constant INC_WRITE : std_logic_vector(2 downto 0) := "100";
  constant DO_READ   : std_logic_vector(2 downto 0) := "101";
  constant READ_WAIT : std_logic_vector(2 downto 0) := "110";

  signal state      : std_logic_vector(2 downto 0);
  signal mem_req    : std_logic;
  signal mem_wr     : std_logic;
  signal mem_addr   : std_logic_vector(BIN_ADDR_WIDTH-1 downto 0);
  signal mem_wdata  : std_logic_vector(COUNT_WIDTH-1 downto 0);
  signal mem_rdata  : std_logic_vector(COUNT_WIDTH-1 downto 0);
  signal mem_rvalid : std_logic;
  signal clear_addr  : unsigned(BIN_ADDR_WIDTH-1 downto 0);
  signal target_addr : std_logic_vector(BIN_ADDR_WIDTH-1 downto 0);
  signal is_read_op  : std_logic;
begin
  u_sram : sram_rw_model
    generic map (ADDR_WIDTH => BIN_ADDR_WIDTH, DATA_WIDTH => COUNT_WIDTH)
    port map (clk => clk, req => mem_req, wr => mem_wr, addr => mem_addr,
              wdata => mem_wdata, rdata => mem_rdata, rvalid => mem_rvalid);

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state       <= IDLE;
        ready       <= '1';
        read_valid  <= '0';
        read_data   <= (others => '0');
        mem_req     <= '0';
        mem_wr      <= '0';
        mem_addr    <= (others => '0');
        mem_wdata   <= (others => '0');
        clear_addr  <= (others => '0');
        target_addr <= (others => '0');
        is_read_op  <= '0';
      else
        read_valid <= '0';
        mem_req    <= '0';
        case state is
          when IDLE =>
            ready <= '1';
            if clear = '1' then
              ready      <= '0';
              clear_addr <= (others => '0');
              mem_req    <= '1'; mem_wr <= '1';
              mem_addr   <= (others => '0');
              mem_wdata  <= (others => '0');
              state      <= CLEARING;
            elsif data_valid = '1' then
              ready       <= '0';
              target_addr <= data_in;
              is_read_op  <= '0';
              mem_req     <= '1'; mem_wr <= '0';
              mem_addr    <= data_in;
              state       <= INC_READ;
            elsif read_req = '1' then
              ready       <= '0';
              target_addr <= read_addr;
              is_read_op  <= '1';
              mem_req     <= '1'; mem_wr <= '0';
              mem_addr    <= read_addr;
              state       <= DO_READ;
            end if;
          when CLEARING =>
            if clear_addr = NUM_BINS-1 then
              state <= IDLE;
            else
              clear_addr <= clear_addr + 1;
              mem_req    <= '1'; mem_wr <= '1';
              mem_addr   <= std_logic_vector(clear_addr + 1);
              mem_wdata  <= (others => '0');
            end if;
          when INC_READ =>
            state <= INC_WAIT;
          when INC_WAIT =>
            if mem_rvalid = '1' then
              mem_req  <= '1'; mem_wr <= '1';
              mem_addr <= target_addr;
              if unsigned(mem_rdata) = 2**COUNT_WIDTH - 1 then
                mem_wdata <= (others => '1');
              else
                mem_wdata <= std_logic_vector(unsigned(mem_rdata) + 1);
              end if;
              state <= INC_WRITE;
            end if;
          when INC_WRITE =>
            state <= IDLE;
          when DO_READ =>
            state <= READ_WAIT;
          when others =>  -- READ_WAIT
            if mem_rvalid = '1' then
              read_valid <= '1';
              read_data  <= mem_rdata;
              state      <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture rtl;
