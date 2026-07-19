library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_read_ctrl is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    num_reads : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    done : out std_logic;
    checksum : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity mem_read_ctrl;

architecture rtl of mem_read_ctrl is
  component sram_model is
    generic (ADDR_WIDTH : integer := 4; DATA_WIDTH : integer := 8);
    port (
      clk : in std_logic;
      rd_en : in std_logic;
      addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
      rvalid : out std_logic
    );
  end component;

  constant IDLE    : std_logic_vector(1 downto 0) := "00";
  constant READING : std_logic_vector(1 downto 0) := "01";
  constant DONE_ST : std_logic_vector(1 downto 0) := "10";

  signal state         : std_logic_vector(1 downto 0);
  signal addr_cnt      : unsigned(ADDR_WIDTH-1 downto 0);
  signal recv_cnt      : unsigned(ADDR_WIDTH-1 downto 0);
  signal num_reads_reg : unsigned(ADDR_WIDTH-1 downto 0);
  signal mem_rd_en     : std_logic;
  signal mem_addr      : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal checksum_s    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal done_s        : std_logic;

  signal state_n         : std_logic_vector(1 downto 0);
  signal addr_cnt_n      : unsigned(ADDR_WIDTH-1 downto 0);
  signal recv_cnt_n      : unsigned(ADDR_WIDTH-1 downto 0);
  signal num_reads_reg_n : unsigned(ADDR_WIDTH-1 downto 0);
  signal mem_rd_en_n     : std_logic;
  signal mem_addr_n      : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal checksum_n      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal done_n          : std_logic;

  signal mem_rvalid : std_logic;
  signal mem_rdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
  u_sram : sram_model
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (clk => clk, rd_en => mem_rd_en, addr => mem_addr,
              rdata => mem_rdata, rvalid => mem_rvalid);

  -- Combinational next-state
  process(state, addr_cnt, recv_cnt, num_reads_reg, mem_rd_en, mem_addr,
          checksum_s, start, mem_rvalid, mem_rdata, num_reads)
  begin
    state_n         <= state;
    addr_cnt_n      <= addr_cnt;
    recv_cnt_n      <= recv_cnt;
    num_reads_reg_n <= num_reads_reg;
    mem_rd_en_n     <= mem_rd_en;
    mem_addr_n      <= mem_addr;
    checksum_n      <= checksum_s;
    done_n          <= '0';

    case state is
      when IDLE =>
        if start = '1' then
          state_n         <= READING;
          num_reads_reg_n <= unsigned(num_reads);
          addr_cnt_n      <= (others => '0');
          recv_cnt_n      <= (others => '0');
          checksum_n      <= (others => '0');
          mem_addr_n      <= (others => '0');
          mem_rd_en_n     <= '1';
        end if;

      when READING =>
        if mem_rvalid = '1' then
          checksum_n <= checksum_s xor mem_rdata;
          recv_cnt_n <= recv_cnt + 1;
        end if;

        if mem_rd_en = '1' then
          if addr_cnt + 1 < num_reads_reg then
            addr_cnt_n  <= addr_cnt + 1;
            mem_addr_n  <= std_logic_vector(addr_cnt + 1);
            mem_rd_en_n <= '1';
          else
            mem_rd_en_n <= '0';
          end if;
        end if;

        if mem_rvalid = '1' and (recv_cnt + 1 = num_reads_reg) then
          state_n <= DONE_ST;
          done_n  <= '1';
        end if;

      when others =>
        state_n <= IDLE;
    end case;
  end process;

  -- Registered state
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state         <= IDLE;
        mem_addr      <= (others => '0');
        mem_rd_en     <= '0';
        done_s        <= '0';
        checksum_s    <= (others => '0');
        addr_cnt      <= (others => '0');
        recv_cnt      <= (others => '0');
        num_reads_reg <= (others => '0');
      else
        state         <= state_n;
        addr_cnt      <= addr_cnt_n;
        recv_cnt      <= recv_cnt_n;
        num_reads_reg <= num_reads_reg_n;
        mem_rd_en     <= mem_rd_en_n;
        mem_addr      <= mem_addr_n;
        checksum_s    <= checksum_n;
        done_s        <= done_n;
      end if;
    end if;
  end process;

  done     <= done_s;
  checksum <= checksum_s;
end architecture rtl;
