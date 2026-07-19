library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity regfile_max is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    count : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    write_en : in std_logic;
    write_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    busy : out std_logic;
    done : out std_logic;
    max_val : out std_logic_vector(DATA_WIDTH-1 downto 0);
    max_idx : out std_logic_vector(ADDR_WIDTH-1 downto 0)
  );
end entity regfile_max;

architecture rtl of regfile_max is
  component sram_model is
    generic (ADDR_WIDTH : integer := 4; DATA_WIDTH : integer := 8);
    port (clk : in std_logic; rd_en : in std_logic; wr_en : in std_logic;
          addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
          wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
          rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
          rvalid : out std_logic);
  end component;

  constant IDLE    : std_logic_vector(2 downto 0) := "000";
  constant READ    : std_logic_vector(2 downto 0) := "001";
  constant WAIT_ST : std_logic_vector(2 downto 0) := "010";
  constant COMPARE : std_logic_vector(2 downto 0) := "011";
  constant DONE_ST : std_logic_vector(2 downto 0) := "100";

  signal state       : std_logic_vector(2 downto 0);
  signal mem_rd_en   : std_logic;
  signal mem_wr_en   : std_logic;
  signal mem_addr    : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal mem_wdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rdata   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_rvalid  : std_logic;
  signal count_r         : unsigned(ADDR_WIDTH-1 downto 0);
  signal current_idx     : unsigned(ADDR_WIDTH-1 downto 0);
  signal current_max     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal current_max_idx : unsigned(ADDR_WIDTH-1 downto 0);
begin
  u_sram : sram_model
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (clk => clk, rd_en => mem_rd_en, wr_en => mem_wr_en, addr => mem_addr,
              wdata => mem_wdata, rdata => mem_rdata, rvalid => mem_rvalid);

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state           <= IDLE;
        busy            <= '0';
        done            <= '0';
        max_val         <= (others => '0');
        max_idx         <= (others => '0');
        mem_rd_en       <= '0';
        mem_wr_en       <= '0';
        mem_addr        <= (others => '0');
        mem_wdata       <= (others => '0');
        count_r         <= (others => '0');
        current_idx     <= (others => '0');
        current_max     <= (others => '0');
        current_max_idx <= (others => '0');
      else
        done      <= '0';
        mem_rd_en <= '0';
        mem_wr_en <= '0';
        case state is
          when IDLE =>
            busy <= '0';
            if write_en = '1' then
              mem_wr_en <= '1';
              mem_addr  <= write_addr;
              mem_wdata <= write_data;
            end if;
            if start = '1' then
              busy            <= '1';
              count_r         <= unsigned(count);
              current_idx     <= (others => '0');
              current_max     <= (others => '0');
              current_max_idx <= (others => '0');
              if unsigned(count) = 0 then
                max_val <= (others => '0');
                max_idx <= (others => '0');
                state   <= DONE_ST;
              else
                mem_rd_en <= '1';
                mem_addr  <= (others => '0');
                state     <= READ;
              end if;
            end if;
          when READ =>
            state <= WAIT_ST;
          when WAIT_ST =>
            if mem_rvalid = '1' then
              state <= COMPARE;
            end if;
          when COMPARE =>
            if unsigned(mem_rdata) > unsigned(current_max) then
              current_max     <= mem_rdata;
              current_max_idx <= current_idx;
            end if;
            current_idx <= current_idx + 1;
            if current_idx + 1 >= count_r then
              if unsigned(mem_rdata) > unsigned(current_max) then
                max_val <= mem_rdata;
                max_idx <= std_logic_vector(current_idx);
              else
                max_val <= current_max;
                max_idx <= std_logic_vector(current_max_idx);
              end if;
              state <= DONE_ST;
            else
              mem_rd_en <= '1';
              mem_addr  <= std_logic_vector(current_idx + 1);
              state     <= READ;
            end if;
          when others =>  -- DONE_ST
            done  <= '1';
            busy  <= '0';
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;
end architecture rtl;
