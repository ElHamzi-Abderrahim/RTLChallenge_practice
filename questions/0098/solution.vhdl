library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mac_unit is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    clear : in std_logic;
    in_valid : in std_logic;
    in_a : in signed(DATA_WIDTH-1 downto 0);
    in_b : in signed(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_acc : out signed(DATA_WIDTH*2+7 downto 0)
  );
end entity mac_unit;

architecture rtl of mac_unit is
  constant ACC_WIDTH : integer := DATA_WIDTH*2 + 8;

  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant MAC    : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal acc_reg    : std_logic_vector(ACC_WIDTH-1 downto 0);
  signal in_ready_s, out_valid_s, consume : std_logic;
begin
  in_ready_s  <= '1' when state = MAC    else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';
  consume     <= '1' when (state = MAC and in_valid = '1') else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, clear, consume, in_last, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if clear = '1' then next_state <= MAC; end if;
      when MAC =>
        if consume = '1' and in_last = '1' then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
    -- sign-extend both operands to the accumulator width first, then multiply:
    -- the low ACC_WIDTH bits of that product are the correct signed result
    variable a_e, b_e : std_logic_vector(ACC_WIDTH-1 downto 0);
    variable full     : unsigned(2*ACC_WIDTH-1 downto 0);
    variable k        : integer;
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        acc_reg <= (others => '0');
      elsif state = IDLE and next_state = MAC then
        acc_reg <= (others => '0');
      elsif consume = '1' then
        a_e(DATA_WIDTH-1 downto 0) := std_logic_vector(in_a);
        b_e(DATA_WIDTH-1 downto 0) := std_logic_vector(in_b);
        k := DATA_WIDTH;
        while k < ACC_WIDTH loop
          a_e(k) := in_a(DATA_WIDTH-1);
          b_e(k) := in_b(DATA_WIDTH-1);
          k := k + 1;
        end loop;
        full := unsigned(a_e) * unsigned(b_e);
        acc_reg <= std_logic_vector(unsigned(acc_reg) + full(ACC_WIDTH-1 downto 0));
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_acc   <= signed(acc_reg);
end architecture rtl;
