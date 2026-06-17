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
begin
  -- Your implementation here

end architecture rtl;
