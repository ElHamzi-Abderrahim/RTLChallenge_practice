library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity stopwatch_timer is
  port (
    clk : in std_logic;
    reset : in std_logic;
    start : in std_logic;
    clear : in std_logic;
    minutes : out std_logic_vector(5 downto 0);
    seconds : out std_logic_vector(5 downto 0);
    tenths : out std_logic_vector(3 downto 0);
    running : out std_logic
  );
end entity stopwatch_timer;

architecture rtl of stopwatch_timer is
  constant CLKS_PER_TENTH : integer := 10;
  signal min_reg     : unsigned(5 downto 0);
  signal sec_reg     : unsigned(5 downto 0);
  signal tenth_reg   : unsigned(3 downto 0);
  signal running_reg : std_logic;
  signal clk_count   : unsigned(15 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      running_reg <= '0';
    elsif rising_edge(clk) then
      if start = '1' then
        running_reg <= '1';
      else
        running_reg <= '0';
      end if;
    end if;
  end process;

  process(clk, reset)
  begin
    if reset = '1' then
      min_reg   <= (others => '0');
      sec_reg   <= (others => '0');
      tenth_reg <= (others => '0');
      clk_count <= (others => '0');
    elsif rising_edge(clk) then
      if clear = '1' then
        min_reg   <= (others => '0');
        sec_reg   <= (others => '0');
        tenth_reg <= (others => '0');
        clk_count <= (others => '0');
      elsif start = '1' then
        if clk_count = CLKS_PER_TENTH - 1 then
          clk_count <= (others => '0');
          if tenth_reg = 9 then
            tenth_reg <= (others => '0');
            if sec_reg = 59 then
              sec_reg <= (others => '0');
              if min_reg = 59 then
                min_reg <= (others => '0');
              else
                min_reg <= min_reg + 1;
              end if;
            else
              sec_reg <= sec_reg + 1;
            end if;
          else
            tenth_reg <= tenth_reg + 1;
          end if;
        else
          clk_count <= clk_count + 1;
        end if;
      end if;
    end if;
  end process;

  minutes <= std_logic_vector(min_reg);
  seconds <= std_logic_vector(sec_reg);
  tenths  <= std_logic_vector(tenth_reg);
  running <= running_reg;
end architecture rtl;
