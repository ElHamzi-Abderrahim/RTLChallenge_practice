library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity diff_calc is
  generic (
    DATA_WIDTH : integer := 8
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
    out_diff : out signed(DATA_WIDTH downto 0)
  );
end entity diff_calc;

architecture rtl of diff_calc is
  signal prev_value  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal has_prev    : std_logic;
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal in_hs, out_hs : std_logic;
begin
  in_hs  <= in_valid and in_ready_s;
  out_hs <= out_valid_s and out_ready;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        in_ready_s  <= '0';
        out_valid_s <= '0';
        out_diff    <= (others => '0');
        prev_value  <= (others => '0');
        has_prev    <= '0';
      else
        if start = '1' then
          in_ready_s  <= '1';
          out_valid_s <= '0';
          has_prev    <= '0';
        else
          if out_hs = '1' then
            out_valid_s <= '0';
          end if;

          if in_hs = '1' then
            if has_prev = '0' then
              prev_value <= in_data;
              has_prev   <= '1';
            else
              out_diff    <= signed(unsigned('0' & in_data) - unsigned('0' & prev_value));
              out_valid_s <= '1';
              prev_value  <= in_data;
              in_ready_s  <= '0';
            end if;
          end if;

          if out_valid_s = '0' or out_hs = '1' then
            in_ready_s <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
