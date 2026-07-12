library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_divider is
  generic (
    DIVIDE_FACTOR : integer := 2
  );
  port (
    clk_in : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    clk_out : out std_logic
  );
end entity clock_divider;

architecture rtl of clock_divider is
  signal counter     : integer range 0 to DIVIDE_FACTOR;
  signal clk_out_reg : std_logic;
begin
  process(clk_in)
  begin
    if rising_edge(clk_in) then
      if reset = '1' then
        counter     <= 0;
        clk_out_reg <= '0';
      elsif enable = '1' then
        if counter = (DIVIDE_FACTOR/2) - 1 then
          counter     <= 0;
          clk_out_reg <= not clk_out_reg;
        else
          counter <= counter + 1;
        end if;
      else
        clk_out_reg <= '0';
      end if;
    end if;
  end process;

  clk_out <= clk_out_reg when enable = '1' else '0';
end architecture rtl;
