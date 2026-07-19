library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lut_interpolator is
  generic (
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8;
    FRAC_BITS : integer := 4
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    phase : in std_logic_vector(ADDR_WIDTH+FRAC_BITS-1 downto 0);
    done : out std_logic;
    result : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity lut_interpolator;

architecture rtl of lut_interpolator is
  component rom_model is
    generic (ADDR_WIDTH : integer := 4; DATA_WIDTH : integer := 8);
    port (
      clk : in std_logic;
      rd_en : in std_logic;
      addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      rdata : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  constant FSCALE : integer := 2**FRAC_BITS;

  constant IDLE    : std_logic_vector(2 downto 0) := "000";
  constant READ_Y0 : std_logic_vector(2 downto 0) := "001";
  constant READ_Y1 : std_logic_vector(2 downto 0) := "010";
  constant COMPUTE : std_logic_vector(2 downto 0) := "011";
  constant DONE_ST : std_logic_vector(2 downto 0) := "100";

  signal state     : std_logic_vector(2 downto 0);
  signal rom_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rom_rd_en : std_logic;
  signal done_s    : std_logic;
  signal result_s  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal addr_int  : unsigned(ADDR_WIDTH-1 downto 0);
  signal frac      : std_logic_vector(FRAC_BITS-1 downto 0);
  signal y0        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal y1        : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal state_n     : std_logic_vector(2 downto 0);
  signal rom_addr_n  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal rom_rd_en_n : std_logic;
  signal done_n      : std_logic;
  signal result_n    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal addr_int_n  : unsigned(ADDR_WIDTH-1 downto 0);
  signal frac_n      : std_logic_vector(FRAC_BITS-1 downto 0);
  signal y0_n        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal y1_n        : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal rom_rdata     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal interp_result : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
  u_rom : rom_model
    generic map (ADDR_WIDTH => ADDR_WIDTH, DATA_WIDTH => DATA_WIDTH)
    port map (clk => clk, rd_en => rom_rd_en, addr => rom_addr, rdata => rom_rdata);

  -- Linear interpolation: y0 + (y1-y0)*frac/2^F  ==  (y0*(2^F-frac) + y1*frac)/2^F
  process(y0, y1, frac)
    variable iy0, iy1, ifr, res : integer;
  begin
    iy0 := to_integer(unsigned(y0));
    iy1 := to_integer(unsigned(y1));
    ifr := to_integer(unsigned(frac));
    res := (iy0 * (FSCALE - ifr) + iy1 * ifr) / FSCALE;
    interp_result <= std_logic_vector(to_unsigned(res, DATA_WIDTH));
  end process;

  -- Combinational next-state
  process(state, start, phase, rom_rdata, addr_int, frac, y0, y1,
          rom_addr, rom_rd_en, result_s, interp_result)
  begin
    state_n     <= state;
    rom_addr_n  <= rom_addr;
    rom_rd_en_n <= rom_rd_en;
    done_n      <= '0';
    result_n    <= result_s;
    addr_int_n  <= addr_int;
    frac_n      <= frac;
    y0_n        <= y0;
    y1_n        <= y1;

    case state is
      when IDLE =>
        if start = '1' then
          addr_int_n  <= unsigned(phase(ADDR_WIDTH+FRAC_BITS-1 downto FRAC_BITS));
          frac_n      <= phase(FRAC_BITS-1 downto 0);
          rom_addr_n  <= phase(ADDR_WIDTH+FRAC_BITS-1 downto FRAC_BITS);
          rom_rd_en_n <= '1';
          state_n     <= READ_Y0;
        end if;

      when READ_Y0 =>
        y0_n       <= rom_rdata;
        rom_addr_n <= std_logic_vector(addr_int + 1);
        state_n    <= READ_Y1;

      when READ_Y1 =>
        y1_n        <= rom_rdata;
        rom_rd_en_n <= '0';
        state_n     <= COMPUTE;

      when COMPUTE =>
        result_n <= interp_result;
        done_n   <= '1';
        state_n  <= DONE_ST;

      when others =>
        state_n <= IDLE;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state     <= IDLE;
        rom_addr  <= (others => '0');
        rom_rd_en <= '0';
        done_s    <= '0';
        result_s  <= (others => '0');
        addr_int  <= (others => '0');
        frac      <= (others => '0');
        y0        <= (others => '0');
        y1        <= (others => '0');
      else
        state     <= state_n;
        rom_addr  <= rom_addr_n;
        rom_rd_en <= rom_rd_en_n;
        done_s    <= done_n;
        result_s  <= result_n;
        addr_int  <= addr_int_n;
        frac      <= frac_n;
        y0        <= y0_n;
        y1        <= y1_n;
      end if;
    end if;
  end process;

  done   <= done_s;
  result <= result_s;
end architecture rtl;
