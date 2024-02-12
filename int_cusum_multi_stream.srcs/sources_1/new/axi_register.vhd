library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi_register is
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
end axi_register;

architecture Behavioral of axi_register is

type state_type is (READ_OPERANDS, WRITE_RESULT);
signal state : state_type := READ_OPERANDS;

signal result : STD_LOGIC_VECTOR (WIDTH - 1 downto 0) := (others => '0');

signal internal_ready, external_ready : STD_LOGIC := '0';

begin

    s_axis_tready <= internal_ready;
--    s_axis_tready <= external_ready;
    
--    internal_ready <= '1' when state = READ_OPERANDS and s_axis_aresetn = '1' else '0';
    internal_ready <= '1' when state = READ_OPERANDS else '0';
    external_ready <= internal_ready and s_axis_tvalid;
    
    m_axis_tvalid <= '1' when state = WRITE_RESULT else '0';
    m_axis_tdata <= result;
    
    process(s_axis_aclk)
    begin
        if s_axis_aresetn = '0' then
            state <= READ_OPERANDS;
        else
            if rising_edge(s_axis_aclk) then
                case state is
                    when READ_OPERANDS =>
                        if external_ready = '1' and s_axis_tvalid = '1' then
                            result <= s_axis_tdata;
                            state <= WRITE_RESULT;
                        end if;    
                    
                    when WRITE_RESULT =>
                        if m_axis_tready = '1' then
                            state <= READ_OPERANDS;
                        end if;
                end case;
            end if;
        end if;
        
    end process;

end Behavioral;
