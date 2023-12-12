library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity multi_stream_int_max is
    Port ( aclk : in STD_LOGIC;
       a_valid : in STD_LOGIC;
       a_ready : out STD_LOGIC;
       a_data : in STD_LOGIC_VECTOR (63 downto 0);
       b_valid : in STD_LOGIC;
       b_ready : out STD_LOGIC;
       b_data : in STD_LOGIC_VECTOR (63 downto 0);
       max_valid : out STD_LOGIC;
       max_ready : in STD_LOGIC;
       max_data : out STD_LOGIC_VECTOR (63 downto 0));
end multi_stream_int_max;

architecture Behavioral of multi_stream_int_max is

type state_type is (READ_OPERANDS, WRITE_RESULT);
signal state : state_type := READ_OPERANDS;

signal res_valid : STD_LOGIC := '0';
signal a_ready_i, b_ready_i : STD_LOGIC := '0';
signal result : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');

signal external_ready, internal_ready, inputs_valid : STD_LOGIC;

begin

    --a_ready <= a_ready_i;
    --b_ready <= b_ready_i;
    
    a_ready <= external_ready;
    b_ready <= external_ready;
    
    internal_ready <= '1' when state = READ_OPERANDS else '0';
    inputs_valid <= a_valid and b_valid;
    external_ready <= internal_ready and inputs_valid;
    
    max_valid <= '1' when state = WRITE_RESULT else '0';
    max_data <= result;
    
    process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
                when READ_OPERANDS =>
                    if external_ready = '1' and inputs_valid = '1' then
                        if a_data(63 downto 32) > b_data(63 downto 32) then
                            result <= a_data;
                        else
--                            result <= b_data(63 downto 32) & a_data(31 downto 0);
                            result <= b_data;
                        end if; 
                            
                        state <= WRITE_RESULT;
                    end if;
                
                when WRITE_RESULT =>
                    if max_ready = '1' then
                        state <= READ_OPERANDS;
                    end if;
                
            end case;
        end if;
    end process;
    
--    a_ready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and b_valid = '0')) else '1';
--    b_ready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and a_valid = '0')) else '1';
    
--    max_valid <= '1' when state = WRITE_RESULT else '0';
    
--    max_data <= result;
    
--    process(aclk)
--    begin
--        if rising_edge(aclk) then
--            case state is
--                when READ_OPERANDS =>
--                    --a_ready_i <= '1';
--                    --b_ready_i <= '1';
                
--                    if a_valid = '1' and b_valid = '1' then
--                        if a_data > b_data then
--                            result <= a_data;
--                        else
--                            result <= b_data;
--                        end if;
                        
--                        state <= WRITE_RESULT;
                        
--                    --else
--                        --a_ready_i <= '0';
--                        --b_ready_i <= '0';    
                       
--                    end if;
         
--                when WRITE_RESULT =>
--                    --a_ready_i <= '0';
--                    --b_ready_i <= '0';
                
--                    if max_ready = '1' then
--                        state <= READ_OPERANDS;
--                    end if;
            
--            end case;
--        end if;
--    end process;

end Behavioral;
