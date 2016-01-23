library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lut4_tb is
end lut4_tb;

architecture arch_lut4_tb of lut4_tb is
    signal clk_s : std_logic := '0';
    signal rst_s : std_logic;
    signal select_s : std_logic_vector(3 downto 0);
    signal mode_s, prog_i_s, prog_o_s, data_s : std_logic;

    type state_t is (
        idle_st, reset_st, prog_st, run_st
    );
    signal state : state_t := reset_st;
    signal next_state : state_t;

    signal prog_counter_s : integer;
    signal run_counter_s  : integer;

    signal reset_counters_s : std_logic;
    signal inc_prog_counter_s : std_logic;
    signal inc_run_counter_s  : std_logic;

    constant program_xor : std_logic_vector(16 downto 0) := "10110100110010110";
    constant program_or  : std_logic_vector(16 downto 0) := "10111111111111111";
    constant program_and : std_logic_vector(16 downto 0) := "10000000000000001";

begin

    lut4: entity work.lut4
    port map(
        clk_i => clk_s,
        rst_i => rst_s,
        select_i => select_s,
        mode_i => mode_s,
        prog_i => prog_i_s,
        prog_o => prog_o_s,
        data_o => data_s
    );

    clk_s <= not clk_s after 5 ns;
    rst_s <= '1', '0' after 10 ns;

    comb: process(state, prog_counter_s, run_counter_s)
    begin
        next_state <= state;
        select_s <= (others => '0');
        mode_s   <= '0';
        prog_i_s <= '0';

        reset_counters_s <= '0';

        inc_prog_counter_s <= '0';
        inc_run_counter_s  <= '0';

        case state is
            when reset_st =>
                reset_counters_s <= '1';
                next_state <= prog_st;
            when prog_st =>
                if prog_counter_s >= 17 then
                    next_state <= run_st;
                else
                    inc_prog_counter_s <= '1';
                    prog_i_s <= program_xor(prog_counter_s);
                    mode_s <= '1';
                end if;
            when run_st =>
                if run_counter_s >= 0 and run_counter_s <= 15 then
                    select_s(3 downto 0) <= std_logic_vector(to_unsigned(run_counter_s, 4));
                    inc_run_counter_s <= '1';
                elsif run_counter_s >= 16 then
                    next_state <= idle_st;
                else
                end if;
            when others => null;
        end case;
    end process;

    seq: process(clk_s)
    begin
        if rising_edge(clk_s) then
            state <= next_state;

            if rst_s = '1' then
                state <= reset_st;
            end if;

            if reset_counters_s = '1' then
                prog_counter_s <= 0;
                run_counter_s <= 0;
            end if;
            if inc_prog_counter_s = '1' then
                prog_counter_s <= prog_counter_s + 1;
            end if;
            if inc_run_counter_s = '1' then
                run_counter_s <= run_counter_s + 1;
            end if;
        end if;
    end process;

end arch_lut4_tb;
