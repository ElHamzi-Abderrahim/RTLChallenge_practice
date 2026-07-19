library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity relu_unit is
  generic (
    DATA_WIDTH : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_data : in signed(DATA_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out signed(DATA_WIDTH-1 downto 0)
  );
end entity relu_unit;

architecture rtl of relu_unit is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant OUTPUT : std_logic_vector(1 downto 0) := "01";

  signal state      : std_logic_vector(1 downto 0);
  signal next_state : std_logic_vector(1 downto 0);
  signal result_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal in_ready_s, out_valid_s : std_logic;
begin
  in_ready_s  <= '1' when state = IDLE   else '0';
  out_valid_s <= '1' when state = OUTPUT else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then state <= IDLE; else state <= next_state; end if;
    end if;
  end process;

  process(state, in_valid, in_ready_s, out_valid_s, out_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if in_valid = '1' and in_ready_s = '1' then next_state <= OUTPUT; end if;
      when others =>
        if out_valid_s = '1' and out_ready = '1' then next_state <= IDLE; end if;
    end case;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        result_reg <= (others => '0');
      elsif state = IDLE and next_state = OUTPUT then
        if in_data(DATA_WIDTH-1) = '1' then
          result_reg <= (others => '0');
        else
          result_reg <= std_logic_vector(in_data);
        end if;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
  out_data  <= signed(result_reg);
end architecture rtl;
