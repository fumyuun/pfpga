library IEEE;
use IEEE.std_logic_1164.all;

-- data_r
-- +--+
-- |  |----------------+
-- |  |--|\            |
-- |  |--| \--+--------|\
-- |  |--| /  |  _  +--|/--------
-- |  |--|/|  +-|_|-+
-- +--+   ||     |
--      select   clk

entity cell is
    port (
        clk_i : in std_logic;
        rst_i : in std_logic;
        select_i : in std_logic_vector(1 downto 0);
        mode_i : in std_logic;
        prog_i : in std_logic;
        prog_o : out std_logic;
        data_o : out std_logic
    );
end cell;

architecture behav of cell is
    signal data_r     : std_logic_vector(4 downto 0);
    signal dmuxed_s   : std_logic;
    signal skip_reg_s : std_logic;
    signal reg_r      : std_logic;
begin


    prog_o     <= data_r(0);
    skip_reg_s <= data_r(4);

    data_o <= dmuxed_s when skip_reg_s = '1' else reg_r;

    comb: process(select_i, data_r)
    begin
        case select_i is
            when "00"   => dmuxed_s <= data_r(0);
            when "01"   => dmuxed_s <= data_r(1);
            when "10"   => dmuxed_s <= data_r(2);
            when "11"   => dmuxed_s <= data_r(3);
            when others => dmuxed_s <= 'U';
        end case;
    end process;

    seq: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                reg_r  <= '0';
                data_r <= "00000";
            else
                reg_r <= dmuxed_s;

                if mode_i = '1' then
                    data_r(0) <= data_r(1);
                    data_r(1) <= data_r(2);
                    data_r(2) <= data_r(3);
                    data_r(3) <= data_r(4);
                    data_r(4) <= prog_i;
                end if;
            end if;
        end if;
    end process;
end behav;