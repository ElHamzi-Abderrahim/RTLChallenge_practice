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
begin
  -- Your implementation here

end architecture rtl;
