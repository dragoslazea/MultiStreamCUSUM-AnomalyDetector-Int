library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stream_selector is
    Generic (
        NUM_SENSORS : integer := 2
    );
    Port (
        -- control inputs
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- data inputs
        input_value_data : in STD_LOGIC_VECTOR (63 downto 0);
        input_value_ready : out STD_LOGIC;
        input_value_valid : in STD_LOGIC;
        
        -- data outputs
        current_sensor_data : out STD_LOGIC_VECTOR (63 downto 0);
        current_sensor_ready : in STD_LOGIC;
        current_sensor_valid : out STD_LOGIC;
       
        previous_sensor_data : out STD_LOGIC_VECTOR (63 downto 0);
        previous_sensor_ready : in STD_LOGIC;
        previous_sensor_valid : out STD_LOGIC
    );
end stream_selector;

architecture Behavioral of stream_selector is

type state_type is (READ_OPERANDS, WRITE_RESULT);
signal state : state_type := READ_OPERANDS;

signal internal_ready, inputs_valid, res_valid : STD_LOGIC := '0';
signal current_value, previous_value : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');

type previous_type is array (0 to NUM_SENSORS - 1) of std_logic_vector(31 downto 0);
signal previous_values : previous_type := (others => (others => '0'));

begin
    
    internal_ready <= '1' when state = READ_OPERANDS else '0';
    
    previous_sensor_valid <= '1' when state = WRITE_RESULT and previous_sensor_ready = '1' and current_sensor_ready = '1' else '0';
    current_sensor_valid <= '1' when state = WRITE_RESULT and current_sensor_ready = '1' and previous_sensor_ready = '1' else '0';
    
    input_value_ready <= internal_ready;
    
    current_sensor_data <= current_value;
    previous_sensor_data <= previous_value;
    
    process(clk)
    begin
        if rst = '0' then 
            state <= READ_OPERANDS;
            previous_values <= (others => (others => '0'));
        else
            if rising_edge(clk) then
                case state is
                    when READ_OPERANDS =>
                        if input_value_valid = '1' then
                            current_value <= input_value_data;
                            previous_value <= previous_values(to_integer(unsigned(input_value_data(31 downto 16)))) & input_value_data(31 downto 0);
                            
                            state <= WRITE_RESULT;
                        end if;    
                    
                    when WRITE_RESULT =>
                        if current_sensor_ready = '1' and previous_sensor_ready = '1' then
                            previous_values(to_integer(unsigned(current_value(31 downto 16)))) <= current_value(63 downto 32);
                            
                            state <= READ_OPERANDS;
                        end if;
                end case;
            end if;
        end if;
    end process;


end Behavioral;
