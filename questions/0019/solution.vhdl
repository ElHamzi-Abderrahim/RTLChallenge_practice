library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity priority_encoder is
  port (
    data_i : in std_logic_vector(3 downto 0);
    valid_o : out std_logic;
    pos_o : out std_logic_vector(1 downto 0)
  );
end entity priority_encoder;

architecture rtl of priority_encoder is
begin
  -- Valid signal: high when any bit is active
  valid_o <= '0' when data_i = "0000" else '1';

  -- Priority encoding: LSB has highest priority
  process(data_i)
  begin
    if data_i(0) = '1' then
      pos_o <= "00";
    elsif data_i(1) = '1' then
      pos_o <= "01";
    elsif data_i(2) = '1' then
      pos_o <= "10";
    elsif data_i(3) = '1' then
      pos_o <= "11";
    else
      pos_o <= "XX";
    end if;
  end process;
end architecture rtl;
