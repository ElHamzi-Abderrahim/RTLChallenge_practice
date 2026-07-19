library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity merge_sorted is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    in_a_valid : in std_logic;
    in_a_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_a_last : in std_logic;
    in_b_valid : in std_logic;
    in_b_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    in_b_last : in std_logic;
    out_ready : in std_logic;
    in_a_ready : out std_logic;
    in_b_ready : out std_logic;
    out_valid : out std_logic;
    out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_last : out std_logic
  );
end entity merge_sorted;

architecture rtl of merge_sorted is
  signal buf_a, buf_b : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal buf_a_valid, buf_b_valid : std_logic;
  signal buf_a_last, buf_b_last : std_logic;
  signal a_done, b_done : std_logic;
  signal in_a_ready_s, in_b_ready_s, out_valid_s : std_logic;
  signal a_hs, b_hs, out_hs : std_logic;
begin
  a_hs   <= in_a_valid and in_a_ready_s;
  b_hs   <= in_b_valid and in_b_ready_s;
  out_hs <= out_valid_s and out_ready;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        buf_a <= (others => '0'); buf_b <= (others => '0');
        buf_a_valid <= '0'; buf_b_valid <= '0';
        buf_a_last <= '0'; buf_b_last <= '0';
        a_done <= '0'; b_done <= '0';
        in_a_ready_s <= '1'; in_b_ready_s <= '1';
        out_valid_s <= '0'; out_data <= (others => '0'); out_last <= '0';
      else
        if out_hs = '1' then
          out_valid_s <= '0';
          out_last    <= '0';
        end if;

        if a_hs = '1' then
          buf_a <= in_a_data; buf_a_valid <= '1'; buf_a_last <= in_a_last; in_a_ready_s <= '0';
        end if;
        if b_hs = '1' then
          buf_b <= in_b_data; buf_b_valid <= '1'; buf_b_last <= in_b_last; in_b_ready_s <= '0';
        end if;

        if out_valid_s = '0' or out_hs = '1' then
          if buf_a_valid = '1' and buf_b_valid = '1' then
            if unsigned(buf_a) <= unsigned(buf_b) then
              out_valid_s <= '1'; out_data <= buf_a; buf_a_valid <= '0'; in_a_ready_s <= not buf_a_last;
              if buf_a_last = '1' then a_done <= '1'; end if;
              out_last <= '0';
            else
              out_valid_s <= '1'; out_data <= buf_b; buf_b_valid <= '0'; in_b_ready_s <= not buf_b_last;
              if buf_b_last = '1' then b_done <= '1'; end if;
              out_last <= '0';
            end if;
          elsif buf_a_valid = '1' and (b_done = '1' or buf_b_last = '1') then
            out_valid_s <= '1'; out_data <= buf_a; out_last <= buf_a_last; buf_a_valid <= '0'; in_a_ready_s <= not buf_a_last;
            if buf_a_last = '1' then a_done <= '1'; end if;
          elsif buf_b_valid = '1' and (a_done = '1' or buf_a_last = '1') then
            out_valid_s <= '1'; out_data <= buf_b; out_last <= buf_b_last; buf_b_valid <= '0'; in_b_ready_s <= not buf_b_last;
            if buf_b_last = '1' then b_done <= '1'; end if;
          end if;
        end if;

        if buf_a_valid = '0' and a_done = '0' and in_a_ready_s = '0' then
          in_a_ready_s <= '1';
        end if;
        if buf_b_valid = '0' and b_done = '0' and in_b_ready_s = '0' then
          in_b_ready_s <= '1';
        end if;
      end if;
    end if;
  end process;

  in_a_ready <= in_a_ready_s;
  in_b_ready <= in_b_ready_s;
  out_valid  <= out_valid_s;
end architecture rtl;
