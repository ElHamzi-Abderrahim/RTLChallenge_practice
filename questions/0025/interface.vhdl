library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_fifo is
  generic (
    DEPTH : integer := 4;
    DATA_W : integer := 1
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    push_i : in std_logic;
    push_data_i : in std_logic_vector(DATA_W-1 downto 0);
    pop_i : in std_logic;
    pop_data_o : out std_logic_vector(DATA_W-1 downto 0);
    full_o : out std_logic;
    empty_o : out std_logic
  );
end entity sync_fifo;

architecture rtl of sync_fifo is
begin
  -- Your implementation here

end architecture rtl;
