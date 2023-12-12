library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity multi_stream_int_adder_subtractor is
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
end multi_stream_int_adder_subtractor;

architecture Behavioral of multi_stream_int_adder_subtractor is

type state_type is (READ_OPERANDS, WRITE_RESULT);
signal state : state_type := READ_OPERANDS;

signal res_valid : STD_LOGIC := '0';
signal result : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');

signal a_ready, b_ready, op_ready : STD_LOGIC := '0';
signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

begin

    --s_axis_a_tready <= '1' when state = READ_OPERANDS and s_axis_a_tvalid = '1' and s_axis_b_tvalid = '1' and s_axis_operation_tvalid = '1' else '0';
    --s_axis_b_tready <= '1' when state = READ_OPERANDS and s_axis_a_tvalid = '1' and s_axis_b_tvalid = '1' and s_axis_operation_tvalid = '1' else '0';
    --s_axis_operation_tready <= '1' when state = READ_OPERANDS and s_axis_a_tvalid = '1' and s_axis_b_tvalid = '1' and s_axis_operation_tvalid = '1' else '0';
    --s_axis_a_tready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and (s_axis_b_tvalid = '0' or s_axis_operation_tvalid = '0'))) else '1';
    --s_axis_b_tready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and (s_axis_a_tvalid = '0' or s_axis_operation_tvalid = '0'))) else '1';
    --s_axis_operation_tready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and (s_axis_a_tvalid = '0' or s_axis_b_tvalid = '0'))) else '1';
    
    s_axis_a_tready <= external_ready;
    s_axis_b_tready <= external_ready;
    s_axis_operation_tready <= external_ready;
    
    internal_ready <= '1' when state = READ_OPERANDS else '0';
    inputs_valid <= s_axis_a_tvalid and s_axis_b_tvalid  and s_axis_operation_tvalid;
    external_ready <= internal_ready and inputs_valid;
    
    m_axis_result_tvalid <= '1' when state = WRITE_RESULT else '0';
    m_axis_result_tdata <= result;
    
    process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
                when READ_OPERANDS =>
                    if external_ready = '1' and inputs_valid = '1' then
                        if s_axis_operation_tdata = "00000000" then
                            result(63 downto 32) <= s_axis_a_tdata(63 downto 32) + s_axis_b_tdata(63 downto 32);
                            result(31 downto 0) <= s_axis_a_tdata(31 downto 0);
                        else
                            result(63 downto 32) <= s_axis_a_tdata(63 downto 32) - s_axis_b_tdata(63 downto 32);
                            result(31 downto 0) <= s_axis_a_tdata(31 downto 0);
                        end if;
                        
                        state <= WRITE_RESULT;
                    end if;    
                
                when WRITE_RESULT =>
                    if m_axis_result_tready = '1' then
                        state <= READ_OPERANDS;
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
