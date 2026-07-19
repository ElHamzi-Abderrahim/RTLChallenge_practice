library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter_manager is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    cmd_valid : in std_logic;
    cmd_op : in std_logic_vector(1 downto 0);
    cmd_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    cmd_wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
    cmd_ready : out std_logic;
    resp_valid : out std_logic;
    resp_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity counter_manager;

architecture rtl of counter_manager is
  component sram_rw_model is
    generic (ADDR_WIDTH : integer := 4; DATA_WIDTH : integer := 8);
    port (clk : in std_logic; req : in std_logic; wr : in std_logic;
          addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
          wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
          rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
          rvalid : out std_logic);
  end component;

  constant OP_NOP   : std_logic_vector(1 downto 0) := "00";
  constant OP_INC   : std_logic_vector(1 downto 0) := "01";
  constant OP_READ  : std_logic_vector(1 downto 0) := "10";
  constant OP_WRITE : std_logic_vector(1 downto 0) := "11";

  constant IDLE      : std_logic_vector(2 downto 0) := "000";
  constant DO_WRITE  : std_logic_vector(2 downto 0) := "001";
  constant DO_READ   : std_logic_vector(2 downto 0) := "010";
  constant WAIT_READ : std_logic_vector(2 downto 0) := "011";
  constant DO_INC_WR : std_logic_vector(2 downto 0) := "100";
  constant DONE      : std_logic_vector(2 downto 0) := "101";

  signal state     : std_logic_vector(2 downto 0);
  signal mem_req   : std_logic;
  signal mem_wr    : std_logic;
  signal mem_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal mem_wdata : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rdata : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rvalid : std_logic;
  signal cmd_op_r    : std_logic_vector(1 downto 0);
  signal cmd_addr_r  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal cmd_wdata_r : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal cmd_ready_s : std_logic;
begin
  u_sram : sram_rw_model
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (clk => clk, req => mem_req, wr => mem_wr, addr => mem_addr,
              wdata => mem_wdata, rdata => mem_rdata, rvalid => mem_rvalid);

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state       <= IDLE;
        cmd_ready_s <= '1';
        resp_valid  <= '0';
        resp_data   <= (others => '0');
        mem_req     <= '0';
        mem_wr      <= '0';
        mem_addr    <= (others => '0');
        mem_wdata   <= (others => '0');
        cmd_op_r    <= "00";
        cmd_addr_r  <= (others => '0');
        cmd_wdata_r <= (others => '0');
      else
        resp_valid <= '0';
        mem_req    <= '0';
        case state is
          when IDLE =>
            cmd_ready_s <= '1';
            if cmd_valid = '1' and cmd_ready_s = '1' then
              cmd_op_r    <= cmd_op;
              cmd_addr_r  <= cmd_addr;
              cmd_wdata_r <= cmd_wdata;
              cmd_ready_s <= '0';
              case cmd_op is
                when OP_NOP =>
                  state <= DONE;
                when OP_WRITE =>
                  mem_req <= '1'; mem_wr <= '1'; mem_addr <= cmd_addr; mem_wdata <= cmd_wdata; state <= DO_WRITE;
                when OP_READ =>
                  mem_req <= '1'; mem_wr <= '0'; mem_addr <= cmd_addr; state <= DO_READ;
                when others =>  -- OP_INC
                  mem_req <= '1'; mem_wr <= '0'; mem_addr <= cmd_addr; state <= DO_READ;
              end case;
            end if;
          when DO_WRITE =>
            state <= DONE;
          when DO_READ =>
            state <= WAIT_READ;
          when WAIT_READ =>
            if mem_rvalid = '1' then
              if cmd_op_r = OP_READ then
                resp_valid <= '1'; resp_data <= mem_rdata; state <= DONE;
              else
                mem_req <= '1'; mem_wr <= '1'; mem_addr <= cmd_addr_r;
                mem_wdata <= std_logic_vector(unsigned(mem_rdata) + 1);
                state <= DO_INC_WR;
              end if;
            end if;
          when DO_INC_WR =>
            state <= DONE;
          when others =>  -- DONE
            cmd_ready_s <= '1';
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  cmd_ready <= cmd_ready_s;
end architecture rtl;
