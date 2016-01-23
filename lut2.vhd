library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------
-- A lut2 fpga cell. Internally, it has a 5-bit program memory with a latch.
-- The select_i muxes the data over the last 4 bits. The first bit is
-- to skip the latch.
-- When mode_i is 1, it enters programming mode. Every clock cycle, prog_i is
-- shifted in the memory, shifting one bit out of prog_i as well.

entity lut2 is
    port (
        clk_i    : in  std_logic;
        rst_i    : in  std_logic;
        select_i : in  std_logic_vector(1 downto 0);
        mode_i   : in  std_logic; -- '1' = programming mode
        prog_i   : in  std_logic;  -- shift input
        prog_o   : out std_logic; -- shift output
        data_o   : out std_logic
    );
end lut2;

architecture behav of lut2 is
    signal data_r     : std_logic_vector(4 downto 0);
    signal dmuxed_s   : std_logic;
    signal skip_latch_s : std_logic;
    signal latch_r      : std_logic;
begin

    prog_o     <= data_r(0);
    skip_latch_s <= data_r(4);

    data_o <= dmuxed_s when skip_latch_s = '1' else latch_r;

    comb: process(select_i, data_r)
    begin
        if select_i >= "00" and select_i <= "11" then
            dmuxed_s <= data_r(to_integer(unsigned(select_i)));
        else
            dmuxed_s <= 'U';
        end if;
    end process;

    seq: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                -- reset
                latch_r  <= '0';
                data_r <= (others => '0');
            else
                latch_r <= dmuxed_s;

                if mode_i = '1' then
                    -- shift in prog_i
                    for n in 0 to 3 loop
                        data_r(n) <= data_r(n+1);
                    end loop;
                    data_r(4) <= prog_i;
                end if;
            end if;
        end if;
    end process;
end behav;