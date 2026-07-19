library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity running_sum is
  generic (
    DATA_WIDTH : integer := 16
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
    out_sum : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity running_sum;

architecture rtl of running_sum is
  signal accumulator : unsigned(DATA_WIDTH-1 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal in_hs  : std_logic;
  signal out_hs : std_logic;
begin
  in_hs  <= in_valid and in_ready_s;
  out_hs <= out_valid_s and out_ready;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        accumulator <= (others => '0');
        out_valid_s <= '0';
        out_sum     <= (others => '0');
        in_ready_s  <= '1';
      else
        if start = '1' then
          accumulator <= (others => '0');
          out_valid_s <= '0';
          in_ready_s  <= '1';
        else
          if out_hs = '1' then
            out_valid_s <= '0';
          end if;
          if in_hs = '1' then
            accumulator <= accumulator + unsigned(in_data);
            out_sum     <= std_logic_vector(accumulator + unsigned(in_data));
            out_valid_s <= '1';
            in_ready_s  <= '0';
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
