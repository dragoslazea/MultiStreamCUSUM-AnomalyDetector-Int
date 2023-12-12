library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity multi_stream_int_threshold_exceeding_detector is
    Port ( aclk : in STD_LOGIC;
           gp_in_valid : in STD_LOGIC;
           gp_in_ready : out STD_LOGIC;
           gp_in_data : in STD_LOGIC_VECTOR (63 downto 0);
           gn_in_valid : in STD_LOGIC;
           gn_in_ready : out STD_LOGIC;
           gn_in_data : in STD_LOGIC_VECTOR (63 downto 0);
           th_valid : in STD_LOGIC;
           th_ready : out STD_LOGIC;
           th_data : in STD_LOGIC_VECTOR (31 downto 0);
           abnormal_valid : out STD_LOGIC;
           abnormal_ready : in STD_LOGIC;
           abnormal_data : out STD_LOGIC;
           gp_out_valid : out STD_LOGIC;
           gp_out_ready : in STD_LOGIC;
           gp_out_data : out STD_LOGIC_VECTOR (63 downto 0);
           gn_out_valid : out STD_LOGIC;
           gn_out_ready : in STD_LOGIC;
           gn_out_data : out STD_LOGIC_VECTOR (63 downto 0));
end multi_stream_int_threshold_exceeding_detector;

architecture Behavioral of multi_stream_int_threshold_exceeding_detector is

type state_type is (READ_OPERANDS, WRITE_RESULT);
signal state : state_type := READ_OPERANDS;

-- output internal signals
signal abnormal : STD_LOGIC := '0';
signal gp_out, gn_out : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');

-- ready signals
signal gp_in_ready_i, gn_in_ready_i, th_ready_i : STD_LOGIC := '0';

-- valid signals
signal abnormal_valid_i, gp_out_valid_i, gn_out_valid_i : STD_LOGIC := '0';
signal internal_ready, external_ready, inputs_valid, outputs_valid, outputs_ready : STD_LOGIC := '0';

begin

    gp_in_ready <= external_ready;
    gn_in_ready <= external_ready;
    th_ready <= external_ready;
    
    internal_ready <= '1' when state = READ_OPERANDS else '0';
    inputs_valid <= gp_in_valid and gn_in_valid  and th_valid;
    external_ready <= internal_ready and inputs_valid;
    
    outputs_ready <= gp_out_ready and gn_out_ready and abnormal_ready;
    outputs_valid <= '1' when outputs_ready = '1' and state = WRITE_RESULT else '0';
    
    abnormal_valid <= outputs_valid;
    gp_out_valid <= outputs_valid;
    gn_out_valid <= outputs_valid;
    
    gp_out_data <= gp_out;
    gn_out_data <= gn_out;
    abnormal_data <= abnormal;
    
    process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
                when READ_OPERANDS =>
                    if external_ready = '1' and inputs_valid = '1' then
                        if gn_in_data(63 downto 32) > th_data or gp_in_data(63 downto 32) > th_data then
                            abnormal <= '1';
                            gn_out(63 downto 32) <= (others => '0');
                            gn_out(31 downto 0) <= gn_in_data(31 downto 0);
                            gp_out(63 downto 32) <= (others => '0');
                            gp_out(31 downto 0) <= gp_in_data(31 downto 0);
                        else
                            abnormal <= '0';
                            gp_out <= gp_in_data;
                            gn_out <= gn_in_data;
                        end if;
                        
                        state <= WRITE_RESULT;
                    end if;    
                
                when WRITE_RESULT =>
                    if outputs_ready = '1' and outputs_valid = '1' then
                        state <= READ_OPERANDS;
                    end if;
            end case;
        end if;
    end process;

    --gp_in_ready <= gp_in_ready_i;
    --gn_in_ready <= gn_in_ready_i;
    --th_ready <= th_ready_i;
    
--    gp_in_ready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and (gn_in_valid = '0' or th_valid = '0'))) else '1';
--    gn_in_ready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and (gp_in_valid = '0' or th_valid = '0'))) else '1';
--    th_ready <= '0' when (state = WRITE_RESULT or (state = READ_OPERANDS and (gn_in_valid = '0' or gp_in_valid = '0'))) else '1';
    
--    abnormal_valid <= '1' when state = WRITE_RESULT else '0';
--    gp_out_valid <= '1' when state = WRITE_RESULT else '0';
--    gn_out_valid <= '1' when state = WRITE_RESULT else '0';
    
--    gp_out_data <= gp_out;
--    gn_out_data <= gn_out;
--    abnormal_data <= abnormal;
    
--    process(aclk)
--    begin
--        if rising_edge(aclk) then
--            case state is
--                when READ_OPERANDS =>
--                    --gp_in_ready_i <= '1';
--                    --gn_in_ready_i <= '1';
--                    --th_ready_i <= '1';
                
--                    if gp_in_valid = '1' and gn_in_valid = '1' and th_valid = '1' then
--                        if gn_in_data > th_data or gp_in_data > th_data then
--                            abnormal <= '1';
--                            gn_out <= (others => '0');
--                            gp_out <= (others => '0');
--                        else
--                            abnormal <= '0';
--                            gp_out <= gp_in_data;
--                            gn_out <= gn_in_data;
--                        end if;
                        
--                        state <= WRITE_RESULT;
                    
--                    --else
--                        --gp_in_ready_i <= '0';
--                        --gn_in_ready_i <= '0';
--                        --th_ready_i <= '0';
--                    end if;
--                when WRITE_RESULT =>
--                    --gp_in_ready_i <= '0';
--                    --gn_in_ready_i <= '0';
--                    --th_ready_i <= '0';
                    
--                    if abnormal_ready = '1' and gp_out_ready = '1' and gn_out_ready = '1' then
--                        state <= READ_OPERANDS;
--                    end if;
                
--            end case;
--        end if;
--    end process;
    
    
--    NEXT_STATE : process (aclk)
--    begin
--        if rising_edge(aclk) then
--            case state is
--                when READ_OPERANDS => 
--                    if gp_in_valid = '1' and gn_in_valid = '1' and th_valid = '1' then
--                        state <= EXECUTE_OPERATION;
--                    else
--                        state <= READ_OPERANDS;
--                    end if;
--                when EXECUTE_OPERATION =>
--                    state <= WRITE_RESULT;
--                when WRITE_RESULT =>
--                    if abnormal_ready = '1' and gp_out_ready = '1' and gn_out_ready = '1' then
--                        state <= READ_OPERANDS;
--                    else
--                        state <= WRITE_RESULT;
--                    end if;
--                when others => null;
--            end case;
--        end if;
--    end process NEXT_STATE;
    
--    EXECUTION_STEPS : process (state)
--    begin
--        gp_in_ready_i <= '0';
--        gn_in_ready_i <= '0'; 
--        th_ready_i <= '0';
        
--        abnormal_valid_i <= '0';
--        gp_out_valid_i <= '0';
--        gn_out_valid_i <= '0';
        
--        case state is
--            when READ_OPERANDS => 
--                gp_in_ready_i <= '1';
--                gn_in_ready_i <= '1'; 
--                th_ready_i <= '1';
--            when EXECUTE_OPERATION =>
--                if gn_in_data > th_data or gp_in_data > th_data then
--                    abnormal <= '1';
--                    gn_out <= (others => '0');
--                    gp_out <= (others => '0');
--                else
--                    abnormal <= '0';
--                    gp_out <= gp_in_data;
--                    gn_out <= gn_in_data;
--                end if;
--            when WRITE_RESULT =>
--                abnormal_valid_i <= '1';
--                gp_out_valid_i <= '1';
--                gn_out_valid_i <= '1';
--            when others => null;
--        end case;
--    end process EXECUTION_STEPS; 
    
--    abnormal_data <= abnormal;
--    gp_out_data <= gp_out;
--    gn_out_data <= gn_out;
    
--    gp_in_ready <= gp_in_ready_i;
--    gn_in_ready <= gn_in_ready_i;
--    th_ready <= th_ready_i;
    
--    abnormal_valid <= abnormal_valid_i;
--    gp_out_valid <= gp_out_valid_i;
--    gn_out_valid <= gn_out_valid_i;

end Behavioral;
