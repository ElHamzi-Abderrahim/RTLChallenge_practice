library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UpDownCounter is
  port (
    clk : in std_logic;
    rst : in std_logic;
    up_down : in std_logic;
    count : out std_logic_vector(3 downto 0)
  );
end entity UpDownCounter;

architecture rtl of UpDownCounter is
  signal cnt : unsigned(3 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cnt <= (others => '0');
      elsif up_down = '1' then
        if cnt < 15 then
          cnt <= cnt + 1;
        end if;
      else
        if cnt > 0 then
          cnt <= cnt - 1;
        end if;
      end if;
    end if;
  end process;

  count <= std_logic_vector(cnt);
end architecture rtl;
