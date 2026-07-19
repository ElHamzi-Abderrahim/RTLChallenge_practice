library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity matrix_transpose is
  generic (
    DATA_WIDTH : integer := 8;
    MATRIX_SIZE : integer := 4
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
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_last : out std_logic
  );
end entity matrix_transpose;

architecture rtl of matrix_transpose is
  constant TOTAL_SIZE : integer := MATRIX_SIZE * MATRIX_SIZE;

  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant INPUT  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  -- flat row-major storage: element (r,c) lives at r*MATRIX_SIZE + c
  type mat_t is array(0 to TOTAL_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal matrix : mat_t;

  signal state       : std_logic_vector(1 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal in_idx  : integer range 0 to TOTAL_SIZE;
  signal out_idx : integer range 0 to TOTAL_SIZE;
begin
  process(clk)
    variable i   : integer;
    variable nxt : integer;
    variable nr  : integer;
    variable nc  : integer;
    variable idx : integer;
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state <= IDLE; in_ready_s <= '0'; out_valid_s <= '0';
        out_data <= (others => '0'); out_last <= '0';
        in_idx <= 0; out_idx <= 0;
        i := 0;
        while i < TOTAL_SIZE loop
          matrix(i) <= (others => '0');
          i := i + 1;
        end loop;
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            out_last    <= '0';
            if start = '1' then
              state <= INPUT; in_ready_s <= '1'; in_idx <= 0;
            end if;

          when INPUT =>
            if in_valid = '1' and in_ready_s = '1' then
              matrix(in_idx) <= in_data;
              in_idx <= in_idx + 1;
              if in_idx = TOTAL_SIZE-1 then
                in_ready_s  <= '0';
                state       <= OUTPUT;
                out_idx     <= 0;
                out_valid_s <= '1';
                out_data    <= matrix(0);
                if TOTAL_SIZE = 1 then out_last <= '1'; else out_last <= '0'; end if;
              end if;
            end if;

          when others =>  -- OUTPUT
            if out_valid_s = '1' and out_ready = '1' then
              if out_idx = TOTAL_SIZE-1 then
                out_valid_s <= '0';
                out_last    <= '0';
                state       <= IDLE;
              else
                nxt := out_idx + 1;
                nr  := nxt / MATRIX_SIZE;
                nc  := nxt mod MATRIX_SIZE;
                idx := nc * MATRIX_SIZE + nr;
                out_idx  <= nxt;
                out_data <= matrix(idx);
                if nxt = TOTAL_SIZE-1 then out_last <= '1'; else out_last <= '0'; end if;
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
