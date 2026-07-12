library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_interface is
  port (
    clk : in std_logic;
    reset : in std_logic;
    req_i : in std_logic;
    req_rnw_i : in std_logic;
    req_addr_i : in std_logic_vector(3 downto 0);
    req_wdata_i : in std_logic_vector(31 downto 0);
    req_ready_o : out std_logic;
    req_rdata_o : out std_logic_vector(31 downto 0)
  );
end entity mem_interface;

architecture rtl of mem_interface is
  type mem_t is array(0 to 15) of std_logic_vector(31 downto 0);
  signal memory        : mem_t;
  signal delay_counter : unsigned(2 downto 0);
  signal addr_reg      : std_logic_vector(3 downto 0);
  signal rnw_reg       : std_logic;
  signal busy          : std_logic;
  signal req_prev      : std_logic;
  signal req_edge      : std_logic;
begin
  req_edge <= req_i and (not req_prev);

  process(clk, reset)
    variable idx : integer;
  begin
    if reset = '1' then
      delay_counter <= (others => '0');
      addr_reg      <= (others => '0');
      rnw_reg       <= '0';
      busy          <= '0';
      req_prev      <= '0';
      idx := 0;
      while idx <= 15 loop
        memory(idx) <= (others => '0');
        idx := idx + 1;
      end loop;
    elsif rising_edge(clk) then
      req_prev <= req_i;
      if req_edge = '1' then
        busy          <= '1';
        delay_counter <= to_unsigned(3, 3);
        addr_reg      <= req_addr_i;
        rnw_reg       <= req_rnw_i;
      elsif busy = '1' then
        if delay_counter = 0 then
          if rnw_reg = '0' then
            memory(to_integer(unsigned(addr_reg))) <= req_wdata_i;
          end if;
          busy <= '0';
        else
          delay_counter <= delay_counter - 1;
        end if;
      end if;
    end if;
  end process;

  req_ready_o <= '1' when (busy = '1' and delay_counter = 0) else '0';
  req_rdata_o <= memory(to_integer(unsigned(addr_reg)));
end architecture rtl;
