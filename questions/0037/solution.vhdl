library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_transmitter is
  generic (
    CLK_FREQ : integer := 50000000;
    BAUD_RATE : integer := 9600
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    tx_start : in std_logic;
    tx_data : in std_logic_vector(7 downto 0);
    tx_out : out std_logic;
    tx_busy : out std_logic;
    tx_done : out std_logic
  );
end entity uart_transmitter;

architecture rtl of uart_transmitter is
  constant CLKS_PER_BIT   : integer := CLK_FREQ / BAUD_RATE;
  constant s_IDLE         : std_logic_vector(2 downto 0) := "000";
  constant s_TX_START_BIT : std_logic_vector(2 downto 0) := "001";
  constant s_TX_DATA_BITS : std_logic_vector(2 downto 0) := "010";
  constant s_TX_STOP_BIT  : std_logic_vector(2 downto 0) := "011";

  signal r_SM_Main     : std_logic_vector(2 downto 0);
  signal r_Clock_Count : integer;
  signal r_Bit_Index   : integer range 0 to 7;
  signal r_Tx_Data     : std_logic_vector(7 downto 0);
  signal r_Tx_Active   : std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        r_SM_Main     <= s_IDLE;
        r_Clock_Count <= 0;
        r_Bit_Index   <= 0;
        r_Tx_Data     <= (others => '0');
        r_Tx_Active   <= '1';
      else
        case r_SM_Main is
          when s_IDLE =>
            r_Tx_Active   <= '1';
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
            if tx_start = '1' then
              r_Tx_Data <= tx_data;
              r_SM_Main <= s_TX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
            end if;

          when s_TX_START_BIT =>
            r_Tx_Active <= '0';
            if r_Clock_Count < CLKS_PER_BIT - 1 then
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= s_TX_START_BIT;
            else
              r_Clock_Count <= 0;
              r_SM_Main     <= s_TX_DATA_BITS;
            end if;

          when s_TX_DATA_BITS =>
            r_Tx_Active <= r_Tx_Data(r_Bit_Index);
            if r_Clock_Count < CLKS_PER_BIT - 1 then
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= s_TX_DATA_BITS;
            else
              r_Clock_Count <= 0;
              if r_Bit_Index < 7 then
                r_Bit_Index <= r_Bit_Index + 1;
                r_SM_Main   <= s_TX_DATA_BITS;
              else
                r_Bit_Index <= 0;
                r_SM_Main   <= s_TX_STOP_BIT;
              end if;
            end if;

          when s_TX_STOP_BIT =>
            r_Tx_Active <= '1';
            if r_Clock_Count < CLKS_PER_BIT - 1 then
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= s_TX_STOP_BIT;
            else
              r_Clock_Count <= 0;
              r_SM_Main     <= s_IDLE;
            end if;

          when others =>
            r_SM_Main <= s_IDLE;
        end case;
      end if;
    end if;
  end process;

  tx_out  <= r_Tx_Active;
  tx_busy <= '1' when r_SM_Main /= s_IDLE else '0';
  tx_done <= '0';
end architecture rtl;
