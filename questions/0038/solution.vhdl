library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity debounce is
  generic (
    CLK_FREQ : integer := 50000000;
    DEBOUNCE_TIME_MS : integer := 20
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    button_in : in std_logic;
    button_out : out std_logic
  );
end entity debounce;

architecture rtl of debounce is
  constant DEBOUNCE_CYCLES : integer := (CLK_FREQ * DEBOUNCE_TIME_MS) / 1000;
  signal counter      : integer range 0 to DEBOUNCE_CYCLES;
  signal button_sync1 : std_logic;
  signal button_sync2 : std_logic;
  signal button_state : std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        button_sync1 <= '0';
        button_sync2 <= '0';
      else
        button_sync1 <= button_in;
        button_sync2 <= button_sync1;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter      <= 0;
        button_state <= '0';
      else
        if button_sync2 /= button_state then
          if counter = DEBOUNCE_CYCLES - 1 then
            button_state <= button_sync2;
            counter      <= 0;
          else
            counter <= counter + 1;
          end if;
        else
          counter <= 0;
        end if;
      end if;
    end if;
  end process;

  button_out <= button_state;
end architecture rtl;
