library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Universal_Shift_Register is
  port (
    clk : in std_logic;
    reset : in std_logic;
    load : in std_logic;
    shift_l : in std_logic;
    shift_r : in std_logic;
    serial_in : in std_logic;
    enable : in std_logic;
    q : out std_logic_vector(3 downto 0)
  );
end entity Universal_Shift_Register;

architecture rtl of Universal_Shift_Register is
  signal shift_reg : std_logic_vector(3 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        shift_reg <= (others => '0');
      elsif load = '1' then
        shift_reg <= "000" & serial_in;
      elsif enable = '1' then
        if shift_l = '1' then
          shift_reg <= shift_reg(2 downto 0) & shift_reg(3);
        elsif shift_r = '1' then
          shift_reg <= shift_reg(0) & shift_reg(3 downto 1);
        end if;
      end if;
    end if;
  end process;

  q <= shift_reg;
end architecture rtl;
