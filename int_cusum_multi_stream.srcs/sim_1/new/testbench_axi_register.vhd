library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testbench_axi_register is
end testbench_axi_register;

architecture tb of testbench_axi_register is

component axi_register is
    Generic (
        WIDTH : integer := 64
    );
    Port (
        s_axis_aresetn : IN STD_LOGIC;
        s_axis_aclk : IN STD_LOGIC;
        s_axis_tvalid : IN STD_LOGIC;
        s_axis_tready : OUT STD_LOGIC;
        s_axis_tdata : IN STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        m_axis_tvalid : OUT STD_LOGIC;
        m_axis_tready : IN STD_LOGIC;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(WIDTH - 1 downto 0)
    );
end component;

constant T : time := 20 ns;

signal nrst, clk, s_tvalid, m_tvalid, s_tready, m_tready : std_logic := '0';
signal data_in, data_out : std_logic_vector (63 downto 0) := (others => '0');

begin

    clk <= not clk after T / 2;
    
    nrst <= '0', '1' after 5 * T;
    
--    s_tvalid <= '0', '1' after 3 * T, '0' after 6 * T, '1' after 8 * T;
--    m_tready <= '1';
    
    reg : axi_register port map (
        s_axis_aresetn => nrst,
        s_axis_aclk => clk,
        s_axis_tvalid => s_tvalid,
        s_axis_tready => s_tready,
        s_axis_tdata => data_in,
        m_axis_tvalid => m_tvalid,
        m_axis_tready => m_tready,
        m_axis_tdata => data_out
    );
    
    process (clk)
    begin
        if rising_edge(clk) then
            if s_tready = '1' and s_tvalid = '1' then
                data_in <= data_in + 1;
            end if;
        end if;
    end process;
    
    s_tvalid <= not s_tvalid after T;
    m_tready <= not m_tready after 4 * T;

    


end tb;
