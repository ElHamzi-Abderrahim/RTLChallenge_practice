library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pwm_generator is
  generic (
    COUNTER_WIDTH : integer := 8;
    PWM_PERIOD : integer := 256
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    duty_cycle : in std_logic_vector(COUNTER_WIDTH-1 downto 0);
    pwm_out : out std_logic
  );
end entity pwm_generator;

architecture rtl of pwm_generator is
  signal counter : unsigned(COUNTER_WIDTH-1 downto 0);
  signal pwm_reg : std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= (others => '0');
        pwm_reg <= '0';
      elsif enable = '1' then
        if counter = PWM_PERIOD - 1 then
          counter <= (others => '0');
        else
          counter <= counter + 1;
        end if;

        if unsigned(duty_cycle) = 0 then
          pwm_reg <= '0';
        elsif unsigned(duty_cycle) >= PWM_PERIOD then
          pwm_reg <= '1';
        elsif counter < unsigned(duty_cycle) then
          pwm_reg <= '1';
        else
          pwm_reg <= '0';
        end if;
      else
        pwm_reg <= '0';
      end if;
    end if;
  end process;

  pwm_out <= pwm_reg;
end architecture rtl;
