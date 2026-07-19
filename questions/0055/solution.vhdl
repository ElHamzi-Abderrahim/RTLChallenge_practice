library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_arbiter is
  generic (
    NUM_MASTERS : integer := 4;
    ADDR_WIDTH : integer := 8;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    req : in std_logic_vector(NUM_MASTERS-1 downto 0);
    req_wr : in std_logic_vector(NUM_MASTERS-1 downto 0);
    req_addr : in std_logic_vector(NUM_MASTERS*ADDR_WIDTH-1 downto 0);
    req_wdata : in std_logic_vector(NUM_MASTERS*DATA_WIDTH-1 downto 0);
    gnt : out std_logic_vector(NUM_MASTERS-1 downto 0);
    gnt_rdata : out std_logic_vector(NUM_MASTERS*DATA_WIDTH-1 downto 0);
    gnt_rvalid : out std_logic_vector(NUM_MASTERS-1 downto 0)
  );
end entity mem_arbiter;

architecture rtl of mem_arbiter is
  component sram_rw_model is
    generic (ADDR_WIDTH : integer := 8; DATA_WIDTH : integer := 8);
    port (
      clk : in std_logic;
      req : in std_logic;
      wr : in std_logic;
      addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
      rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
      rvalid : out std_logic
    );
  end component;

  type rdata_arr is array(0 to NUM_MASTERS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rdata_reg : rdata_arr;

  signal mem_req    : std_logic;
  signal mem_wr     : std_logic;
  signal mem_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal mem_wdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rvalid : std_logic;

  signal selected_master : integer range 0 to NUM_MASTERS-1;
  signal has_request     : std_logic;
  signal pending_read    : std_logic;
  signal pending_master  : integer range 0 to NUM_MASTERS-1;
  signal gnt_s           : std_logic_vector(NUM_MASTERS-1 downto 0);
  signal gnt_rvalid_s    : std_logic_vector(NUM_MASTERS-1 downto 0);
begin
  u_sram : sram_rw_model
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (clk => clk, req => mem_req, wr => mem_wr, addr => mem_addr,
              wdata => mem_wdata, rdata => mem_rdata, rvalid => mem_rvalid);

  -- Priority encoder: lowest-index requester
  process(req)
    variable sel : integer;
    variable hr  : std_logic;
    variable i   : integer;
  begin
    sel := 0; hr := '0'; i := 0;
    while i < NUM_MASTERS loop
      if req(i) = '1' and hr = '0' then
        sel := i; hr := '1';
      end if;
      i := i + 1;
    end loop;
    selected_master <= sel;
    has_request     <= hr;
  end process;

  process(clk)
    variable j : integer;
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        gnt_s        <= (others => '0');
        gnt_rvalid_s <= (others => '0');
        mem_req      <= '0';
        mem_wr       <= '0';
        mem_addr     <= (others => '0');
        mem_wdata    <= (others => '0');
        pending_read <= '0';
        pending_master <= 0;
        j := 0;
        while j < NUM_MASTERS loop
          rdata_reg(j) <= (others => '0');
          j := j + 1;
        end loop;
      else
        gnt_s        <= (others => '0');
        gnt_rvalid_s <= (others => '0');
        mem_req      <= '0';

        if mem_rvalid = '1' and pending_read = '1' then
          gnt_rvalid_s(pending_master) <= '1';
          rdata_reg(pending_master)    <= mem_rdata;
          pending_read <= '0';
        end if;

        if has_request = '1' and pending_read = '0' then
          mem_req   <= '1';
          mem_addr  <= req_addr(selected_master*ADDR_WIDTH + ADDR_WIDTH-1 downto selected_master*ADDR_WIDTH);
          mem_wr    <= req_wr(selected_master);
          mem_wdata <= req_wdata(selected_master*DATA_WIDTH + DATA_WIDTH-1 downto selected_master*DATA_WIDTH);
          if req_wr(selected_master) = '1' then
            gnt_s(selected_master) <= '1';
          else
            pending_read   <= '1';
            pending_master <= selected_master;
            gnt_s(selected_master) <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  gen_rdata : for g in 0 to NUM_MASTERS-1 generate
    gnt_rdata((g+1)*DATA_WIDTH-1 downto g*DATA_WIDTH) <= rdata_reg(g);
  end generate;

  gnt        <= gnt_s;
  gnt_rvalid <= gnt_rvalid_s;
end architecture rtl;
