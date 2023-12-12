library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_multi_stream_int_adder_subtractor is
end tb_multi_stream_int_adder_subtractor;

architecture Tb of tb_multi_stream_int_adder_subtractor is

component fifo16x64
  Port (
    s_axis_aresetn : IN STD_LOGIC;
    s_axis_aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
end component;

component multi_stream_int_adder_subtractor is
  Port ( 
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tready : OUT STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_operation_tvalid : IN STD_LOGIC;
    s_axis_operation_tready : OUT STD_LOGIC;
    s_axis_operation_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
end component;

constant T : time := 20 ns;

signal clk : STD_LOGIC := '0';
signal nrst : STD_LOGIC := '0';

signal f1_in_data, f1_out_data, f2_in_data, f2_out_data, f3_in_data, f3_out_data : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
signal f1_in_valid, f1_out_valid, f2_in_valid, f2_out_valid, op_valid, res_valid, f3_out_valid, add_input_a_valid, add_input_b_valid : STD_LOGIC;
signal f1_in_ready, f1_out_ready, f2_in_ready, f2_out_ready, op_ready, res_ready, f3_out_ready  : STD_LOGIC;
signal f2_input : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal op_data : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

signal s, p : STD_LOGIC := '0';

begin

    f1 : fifo16x64 port map (
        s_axis_aresetn => nrst,
        s_axis_aclk => clk,
        s_axis_tvalid => f1_in_valid,
        s_axis_tready => f1_in_ready,
        s_axis_tdata => f1_in_data,
        m_axis_tvalid => f1_out_valid,
        m_axis_tready => f1_out_ready,
        m_axis_tdata => f1_out_data
    );
    
    f2 : fifo16x64 port map (
        s_axis_aresetn => nrst,
        s_axis_aclk => clk,
        s_axis_tvalid => f2_in_valid,
        s_axis_tready => f2_in_ready,
        s_axis_tdata => f2_in_data,
        m_axis_tvalid => f2_out_valid,
        m_axis_tready => f2_out_ready,
        m_axis_tdata => f2_out_data
    );
    
    add_input_a_valid <= f1_out_valid and s;
    add_input_b_valid <= f2_out_valid and p;
    
    add_sub : multi_stream_int_adder_subtractor port map (
        aclk => clk,
        s_axis_a_tvalid => add_input_a_valid,
        s_axis_a_tready => f1_out_ready,
        s_axis_a_tdata => f1_out_data,
        s_axis_b_tvalid => add_input_b_valid,
        s_axis_b_tready => f2_out_ready,
        s_axis_b_tdata => f2_out_data,
        s_axis_operation_tvalid => '1',
        s_axis_operation_tready => op_ready,
        s_axis_operation_tdata => op_data,
        m_axis_result_tvalid => res_valid,
        m_axis_result_tready => res_ready,
        m_axis_result_tdata => f3_in_data
    );
    
    f3 : fifo16x64 port map (
        s_axis_aresetn => nrst,
        s_axis_aclk => clk,
        s_axis_tvalid => res_valid,
        s_axis_tready => res_ready,
        s_axis_tdata => f3_in_data,
        m_axis_tvalid => f3_out_valid,
        m_axis_tready => f3_out_ready,
        m_axis_tdata => f3_out_data 
    );
    
    process (clk)
    begin
        if rising_edge(clk) then
            if f2_in_ready = '1' then
                f2_input <= f2_input + 1;
            end if;
        end if;
    end process;
    
    f1_in_data <= x"00000034" & x"00010000"; -- 52
    f2_in_data <= f2_input & x"00010000";
    
    clk <= not clk after T / 2;
    nrst <= '0', '1' after 5 * T;
    
    f1_in_valid <= '0', '1' after 12 * T;
    f2_in_valid <= '0', '1' after 7 * T;
    op_valid <= '0', '1' after 7 * T;
    f3_out_ready <= '0', '1' after 7 * T;
    
    process
    begin
        wait until f1_out_valid = '1';
        
        s <= '1';
        wait for 6 * T;
        s <= '0';
        wait for 4 * T;
        s <= '1';
        
    end process;
    
    process
    begin
        wait until f2_out_valid = '1';
        
        p <= '1';
        wait for 15 * T;
        p <= '0';
        wait for 6 * T;
        p <= '1';
        
    end process;
    
    --op_data <= (others => '0'),  "00000001" after 25 * T;
    

end Tb;
