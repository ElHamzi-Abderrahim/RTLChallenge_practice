library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gcd_calc is
  generic (
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_a : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_b : in std_logic_vector(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_gcd : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity gcd_calc;

architecture rtl of gcd_calc is
  constant IDLE    : std_logic_vector(1 downto 0) := "00";
  constant COMPUTE : std_logic_vector(1 downto 0) := "01";
  constant DONE    : std_logic_vector(1 downto 0) := "10";

  signal state       : std_logic_vector(1 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal reg_a       : unsigned(DATA_WIDTH-1 downto 0);
  signal reg_b       : unsigned(DATA_WIDTH-1 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state       <= IDLE;
        in_ready_s  <= '1';
        out_valid_s <= '0';
        out_gcd     <= (others => '0');
        reg_a       <= (others => '0');
        reg_b       <= (others => '0');
      else
        case state is
          when IDLE =>
            if in_valid = '1' and in_ready_s = '1' then
              in_ready_s <= '0';
              reg_a      <= unsigned(in_a);
              reg_b      <= unsigned(in_b);
              if unsigned(in_a) = 0 and unsigned(in_b) = 0 then
                state <= DONE; out_valid_s <= '1'; out_gcd <= (others => '0');
              elsif unsigned(in_a) = 0 then
                state <= DONE; out_valid_s <= '1'; out_gcd <= in_b;
              elsif unsigned(in_b) = 0 then
                state <= DONE; out_valid_s <= '1'; out_gcd <= in_a;
              else
                state <= COMPUTE;
              end if;
            end if;
          when COMPUTE =>
            if reg_b = 0 then
              state <= DONE; out_valid_s <= '1'; out_gcd <= std_logic_vector(reg_a);
            else
              reg_a <= reg_b;
              reg_b <= reg_a mod reg_b;
            end if;
          when DONE =>
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0';
              in_ready_s  <= '1';
              state       <= IDLE;
            end if;
          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
