library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity round_robin_arbiter is
  port (
    clk : in std_logic;
    reset : in std_logic;
    req_i : in std_logic_vector(3 downto 0);
    gnt_o : out std_logic_vector(3 downto 0)
  );
end entity round_robin_arbiter;

architecture rtl of round_robin_arbiter is
  signal last_gnt : std_logic_vector(1 downto 0);
  signal gnt_next : std_logic_vector(3 downto 0);
begin
  process(req_i, last_gnt)
  begin
    gnt_next <= "0000";
    if req_i /= "0000" then
      case last_gnt is
        when "00" =>
          if    req_i(1) = '1' then gnt_next <= "0010";
          elsif req_i(2) = '1' then gnt_next <= "0100";
          elsif req_i(3) = '1' then gnt_next <= "1000";
          elsif req_i(0) = '1' then gnt_next <= "0001";
          end if;
        when "01" =>
          if    req_i(2) = '1' then gnt_next <= "0100";
          elsif req_i(3) = '1' then gnt_next <= "1000";
          elsif req_i(0) = '1' then gnt_next <= "0001";
          elsif req_i(1) = '1' then gnt_next <= "0010";
          end if;
        when "10" =>
          if    req_i(3) = '1' then gnt_next <= "1000";
          elsif req_i(0) = '1' then gnt_next <= "0001";
          elsif req_i(1) = '1' then gnt_next <= "0010";
          elsif req_i(2) = '1' then gnt_next <= "0100";
          end if;
        when others =>
          if    req_i(0) = '1' then gnt_next <= "0001";
          elsif req_i(1) = '1' then gnt_next <= "0010";
          elsif req_i(2) = '1' then gnt_next <= "0100";
          elsif req_i(3) = '1' then gnt_next <= "1000";
          end if;
      end case;
    end if;
  end process;

  process(clk, reset)
  begin
    if reset = '1' then
      gnt_o <= "0000";
      last_gnt <= "11";
    elsif rising_edge(clk) then
      gnt_o <= gnt_next;
      if gnt_next /= "0000" then
        if    gnt_next(0) = '1' then last_gnt <= "00";
        elsif gnt_next(1) = '1' then last_gnt <= "01";
        elsif gnt_next(2) = '1' then last_gnt <= "10";
        elsif gnt_next(3) = '1' then last_gnt <= "11";
        end if;
      end if;
    end if;
  end process;
end architecture rtl;
