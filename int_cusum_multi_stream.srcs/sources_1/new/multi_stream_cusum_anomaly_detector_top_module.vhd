library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multi_stream_cusum_anomaly_detector_top_module is
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
        
        threshold_data : in STD_LOGIC_VECTOR (31 downto 0);
        threshold_ready : out STD_LOGIC;
        threshold_valid : in STD_LOGIC;
       
        drift_data : in STD_LOGIC_VECTOR (31 downto 0);
        drift_ready : out STD_LOGIC;
        drift_valid : in STD_LOGIC;
       
       -- data outputs
        labeled_data : out STD_LOGIC_VECTOR (63 downto 0);
        labeled_data_ready : in STD_LOGIC;
        labeled_data_valid : out STD_LOGIC;
       
        timestamp_data : out STD_LOGIC_VECTOR (31 downto 0);
        timestamp_ready : in STD_LOGIC;
        timestamp_valid : out STD_LOGIC
    );
end multi_stream_cusum_anomaly_detector_top_module;

architecture Structural of multi_stream_cusum_anomaly_detector_top_module is

component multi_stream_int_cumulative_sums_detector is
    Generic (
        NUM_SENSORS : integer := 2
    );
    Port ( 
        -- control inputs
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
       
        -- data inputs
        current_sensor_in_data : in STD_LOGIC_VECTOR (63 downto 0);
        current_sensor_in_ready : out STD_LOGIC;
        current_sensor_in_valid : in STD_LOGIC;
       
        previous_sensor_in_data : in STD_LOGIC_VECTOR (63 downto 0);
        previous_sensor_in_ready : out STD_LOGIC;
        previous_sensor_in_valid : in STD_LOGIC;
       
        threshold_data : in STD_LOGIC_VECTOR (31 downto 0);
        threshold_ready : out STD_LOGIC;
        threshold_valid : in STD_LOGIC;
       
        drift_data : in STD_LOGIC_VECTOR (31 downto 0);
        drift_ready : out STD_LOGIC;
        drift_valid : in STD_LOGIC;
       
        -- outputs
        labeled_data : out STD_LOGIC_VECTOR (63 downto 0);
        labeled_data_ready : in STD_LOGIC;
        labeled_data_valid : out STD_LOGIC;
       
        timestamp_data : out STD_LOGIC_VECTOR (31 downto 0);
        timestamp_ready : in STD_LOGIC;
        timestamp_valid : out STD_LOGIC);
end component;

component stream_selector is
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
end component;

signal current_sensor_data, previous_sensor_data : STD_LOGIC_VECTOR (63 downto 0);
signal current_sensor_ready, previous_sensor_ready : STD_LOGIC;
signal current_sensor_valid, previous_sensor_valid : STD_LOGIC;

begin


    st_selector : stream_selector generic map (
        NUM_SENSORS => NUM_SENSORS    
    )
    port map(
        clk => clk,
        rst => rst,
        input_value_data => input_value_data,
        input_value_ready => input_value_ready,
        input_value_valid => input_value_valid,
        current_sensor_data => current_sensor_data,
        current_sensor_ready => current_sensor_ready,
        current_sensor_valid => current_sensor_valid,
        previous_sensor_data => previous_sensor_data,
        previous_sensor_ready => previous_sensor_ready,
        previous_sensor_valid => previous_sensor_valid  
    );
    
    cusum : multi_stream_int_cumulative_sums_detector generic map (
        NUM_SENSORS => NUM_SENSORS
    )
    port map (
        clk => clk,
        rst => rst,
        current_sensor_in_data => current_sensor_data,
        current_sensor_in_ready => current_sensor_ready,
        current_sensor_in_valid => current_sensor_valid,
        previous_sensor_in_data => previous_sensor_data,
        previous_sensor_in_ready => previous_sensor_ready,
        previous_sensor_in_valid => previous_sensor_valid,
        drift_data => drift_data,
        drift_ready => drift_ready,
        drift_valid => drift_valid,
        threshold_data => threshold_data,
        threshold_ready => threshold_ready,
        threshold_valid => threshold_valid,
        labeled_data => labeled_data,
        labeled_data_ready => labeled_data_ready,
        labeled_data_valid => labeled_data_valid,
        timestamp_data => timestamp_data,
        timestamp_ready => timestamp_ready,
        timestamp_valid => timestamp_valid
    );
    
end Structural;