library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity min_max is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    start : in std_logic;
    in_valid : in std_logic;
    in_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_last : in std_logic;
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_min : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_max : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity min_max;

architecture rtl of min_max is
  constant IDLE   : std_logic_vector(1 downto 0) := "00";
  constant INPUT  : std_logic_vector(1 downto 0) := "01";
  constant OUTPUT : std_logic_vector(1 downto 0) := "10";

  signal state       : std_logic_vector(1 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal curr_min    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal curr_max    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal first_value : std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state       <= IDLE;
        in_ready_s  <= '0';
        out_valid_s <= '0';
        out_min     <= (others => '0');
        out_max     <= (others => '0');
        curr_min    <= (others => '1');
        curr_max    <= (others => '0');
        first_value <= '1';
      else
        case state is
          when IDLE =>
            out_valid_s <= '0';
            if start = '1' then
              state       <= INPUT;
              in_ready_s  <= '1';
              curr_min    <= (others => '1');
              curr_max    <= (others => '0');
              first_value <= '1';
            end if;
          when INPUT =>
            if in_valid = '1' and in_ready_s = '1' then
              if first_value = '1' then
                curr_min    <= in_data;
                curr_max    <= in_data;
                first_value <= '0';
              else
                if unsigned(in_data) < unsigned(curr_min) then curr_min <= in_data; end if;
                if unsigned(in_data) > unsigned(curr_max) then curr_max <= in_data; end if;
              end if;
              if in_last = '1' then
                in_ready_s  <= '0';
                state       <= OUTPUT;
                out_valid_s <= '1';
                if first_value = '1' then
                  out_min <= in_data;
                  out_max <= in_data;
                else
                  if unsigned(in_data) < unsigned(curr_min) then out_min <= in_data; else out_min <= curr_min; end if;
                  if unsigned(in_data) > unsigned(curr_max) then out_max <= in_data; else out_max <= curr_max; end if;
                end if;
              end if;
            end if;
          when others =>  -- OUTPUT
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0';
              state       <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
