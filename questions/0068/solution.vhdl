library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity factorial is
  generic (
    DATA_WIDTH : integer := 32;
    INPUT_WIDTH : integer := 5
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_valid : in std_logic;
    in_n : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    out_ready : in std_logic;
    in_ready : out std_logic;
    out_valid : out std_logic;
    out_factorial : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity factorial;

architecture rtl of factorial is
  constant IDLE    : std_logic_vector(1 downto 0) := "00";
  constant COMPUTE : std_logic_vector(1 downto 0) := "01";
  constant DONE    : std_logic_vector(1 downto 0) := "10";

  signal state       : std_logic_vector(1 downto 0);
  signal in_ready_s  : std_logic;
  signal out_valid_s : std_logic;
  signal accumulator : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal counter     : unsigned(INPUT_WIDTH-1 downto 0);
begin
  process(clk)
    variable prod : unsigned(DATA_WIDTH+INPUT_WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state         <= IDLE;
        in_ready_s    <= '1';
        out_valid_s   <= '0';
        out_factorial <= (others => '0');
        accumulator   <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
        counter       <= (others => '0');
      else
        case state is
          when IDLE =>
            if in_valid = '1' and in_ready_s = '1' then
              in_ready_s <= '0';
              if unsigned(in_n) <= 1 then
                state         <= DONE;
                out_valid_s   <= '1';
                out_factorial <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
              else
                state       <= COMPUTE;
                accumulator <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
                counter     <= unsigned(in_n);
              end if;
            end if;
          when COMPUTE =>
            prod := unsigned(accumulator) * counter;
            accumulator <= std_logic_vector(prod(DATA_WIDTH-1 downto 0));
            counter     <= counter - 1;
            if counter <= 2 then
              state         <= DONE;
              out_valid_s   <= '1';
              out_factorial <= std_logic_vector(prod(DATA_WIDTH-1 downto 0));
            end if;
          when DONE =>
            if out_valid_s = '1' and out_ready = '1' then
              out_valid_s <= '0';
              in_ready_s  <= '1';
              state       <= IDLE;
            end if;
          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  in_ready  <= in_ready_s;
  out_valid <= out_valid_s;
end architecture rtl;
