library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity traffic_light_controller is
  generic (
    CLK_FREQ : integer := 1000;
    GREEN_TIME_SEC : integer := 10;
    YELLOW_TIME_SEC : integer := 3;
    RED_TIME_SEC : integer := 2
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    enable : in std_logic;
    emergency : in std_logic;
    ns_red : out std_logic;
    ns_yellow : out std_logic;
    ns_green : out std_logic;
    ew_red : out std_logic;
    ew_yellow : out std_logic;
    ew_green : out std_logic
  );
end entity traffic_light_controller;

architecture rtl of traffic_light_controller is
  constant GREEN_CYCLES  : integer := CLK_FREQ * GREEN_TIME_SEC;
  constant YELLOW_CYCLES : integer := CLK_FREQ * YELLOW_TIME_SEC;
  constant RED_CYCLES    : integer := CLK_FREQ * RED_TIME_SEC;

  constant NS_GREEN_EW_RED  : integer := 0;
  constant NS_YELLOW_EW_RED : integer := 1;
  constant ALL_RED_1        : integer := 2;
  constant EW_GREEN_NS_RED  : integer := 3;
  constant EW_YELLOW_NS_RED : integer := 4;
  constant ALL_RED_2        : integer := 5;

  signal state : integer range 0 to 5;
  signal timer : integer;

  signal ns_red_reg, ns_yellow_reg, ns_green_reg : std_logic;
  signal ew_red_reg, ew_yellow_reg, ew_green_reg : std_logic;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      state         <= NS_GREEN_EW_RED;
      timer         <= 0;
      ns_red_reg    <= '0';
      ns_yellow_reg <= '0';
      ns_green_reg  <= '1';
      ew_red_reg    <= '1';
      ew_yellow_reg <= '0';
      ew_green_reg  <= '0';
    elsif rising_edge(clk) then
      if emergency = '1' then
        ns_red_reg    <= '1';
        ns_yellow_reg <= '0';
        ns_green_reg  <= '0';
        ew_red_reg    <= '1';
        ew_yellow_reg <= '0';
        ew_green_reg  <= '0';
        timer         <= 0;
      elsif enable = '1' then
        timer <= timer + 1;
        case state is
          when NS_GREEN_EW_RED =>
            ns_red_reg <= '0'; ns_yellow_reg <= '0'; ns_green_reg <= '1';
            ew_red_reg <= '1'; ew_yellow_reg <= '0'; ew_green_reg <= '0';
            if timer >= GREEN_CYCLES - 1 then
              state <= NS_YELLOW_EW_RED;
              timer <= 0;
            end if;
          when NS_YELLOW_EW_RED =>
            ns_red_reg <= '0'; ns_yellow_reg <= '1'; ns_green_reg <= '0';
            ew_red_reg <= '1'; ew_yellow_reg <= '0'; ew_green_reg <= '0';
            if timer >= YELLOW_CYCLES - 1 then
              state <= ALL_RED_1;
              timer <= 0;
            end if;
          when ALL_RED_1 =>
            ns_red_reg <= '1'; ns_yellow_reg <= '0'; ns_green_reg <= '0';
            ew_red_reg <= '1'; ew_yellow_reg <= '0'; ew_green_reg <= '0';
            if timer >= RED_CYCLES - 1 then
              state <= EW_GREEN_NS_RED;
              timer <= 0;
            end if;
          when EW_GREEN_NS_RED =>
            ns_red_reg <= '1'; ns_yellow_reg <= '0'; ns_green_reg <= '0';
            ew_red_reg <= '0'; ew_yellow_reg <= '0'; ew_green_reg <= '1';
            if timer >= GREEN_CYCLES - 1 then
              state <= EW_YELLOW_NS_RED;
              timer <= 0;
            end if;
          when EW_YELLOW_NS_RED =>
            ns_red_reg <= '1'; ns_yellow_reg <= '0'; ns_green_reg <= '0';
            ew_red_reg <= '0'; ew_yellow_reg <= '1'; ew_green_reg <= '0';
            if timer >= YELLOW_CYCLES - 1 then
              state <= ALL_RED_2;
              timer <= 0;
            end if;
          when ALL_RED_2 =>
            ns_red_reg <= '1'; ns_yellow_reg <= '0'; ns_green_reg <= '0';
            ew_red_reg <= '1'; ew_yellow_reg <= '0'; ew_green_reg <= '0';
            if timer >= RED_CYCLES - 1 then
              state <= NS_GREEN_EW_RED;
              timer <= 0;
            end if;
          when others =>
            state <= NS_GREEN_EW_RED;
            timer <= 0;
        end case;
      end if;
    end if;
  end process;

  ns_red    <= ns_red_reg;
  ns_yellow <= ns_yellow_reg;
  ns_green  <= ns_green_reg;
  ew_red    <= ew_red_reg;
  ew_yellow <= ew_yellow_reg;
  ew_green  <= ew_green_reg;
end architecture rtl;
