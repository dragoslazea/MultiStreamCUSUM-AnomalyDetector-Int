library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multi_stream_int_cumulative_sums_detector is
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
end multi_stream_int_cumulative_sums_detector;

architecture Structural of multi_stream_int_cumulative_sums_detector is

component fifo16x64
  PORT (
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

component multi_stream_int_threshold_exceeding_detector is
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
end component;

component multi_stream_int_max is
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
end component;

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

COMPONENT axis_register_slice
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0) 
  );
END COMPONENT;

-- data signals
signal current_sensor_value : STD_LOGIC_VECTOR (127 downto 0);
signal current_sensor_measurement, previous_sensor_measurement : STD_LOGIC_VECTOR (63 downto 0);
signal current_sensor_measurement_bypass, to_combine_data, combined_data : STD_LOGIC_VECTOR (63 downto 0);
signal s_t_in, s_t_out, gn_t_1, gp_t_1, gn_s_t_in, gp_s_t_in, gn_s_t_out, gp_s_t_out : STD_LOGIC_VECTOR (63 downto 0);
signal gn_s_t_drift_in, gp_s_t_drift_in, gn_s_t_drift_out, gp_s_t_drift_out : STD_LOGIC_VECTOR (63 downto 0);
signal max_gn_in, max_gp_in, max_gn_out, max_gp_out, gn_t, gp_t, gn_fifo_in, gp_fifo_in : STD_LOGIC_VECTOR (63 downto 0);
signal timestamp_i : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal abnormal_flag : STD_LOGIC;
signal s_t_result, tagged_drift, tagged_zero : STD_LOGIC_VECTOR (63 downto 0);

-- ready signals
signal current_sensor_measurement_ready, previous_sensor_measurement_ready : STD_LOGIC;
signal broadcast_ready, combine_ready : STD_LOGIC_VECTOR (1 downto 0);
signal s_t_in_ready, s_t_out_ready, gn_t_1_ready, gp_t_1_ready, gn_s_t_in_ready, gp_s_t_in_ready, gn_s_t_out_ready, gp_s_t_out_ready : STD_LOGIC;
signal gn_s_t_drift_in_ready, gp_s_t_drift_in_ready, gn_s_t_drift_out_ready, gp_s_t_drift_out_ready : STD_LOGIC;
signal max_gn_in_ready, max_gp_in_ready, max_gn_out_ready, max_gp_out_ready, gn_t_ready, gp_t_ready, gn_fifo_in_ready, gp_fifo_in_ready : STD_LOGIC;
signal timestamp_in_ready, s_t_op_ready, gn_s_t_op_ready, gp_s_t_op_ready, gn_s_t_drift_op_ready, gp_s_t_drift_op_ready, max_gn_op_ready, max_gp_op_ready : STD_LOGIC;
signal gn_s_t_ready, gp_s_t_ready : STD_LOGIC;
signal max_gn_0_ready, max_gp_0_ready : STD_LOGIC;
signal abnormal_flag_ready : STD_LOGIC;
signal timestamp_out_ready : STD_LOGIC;
signal s_t_result_ready : STD_LOGIC;
signal gn_drift_ready, gp_drift_ready : STD_LOGIC;

-- valid signals
signal current_sensor_measurement_valid, previous_sensor_measurement_valid : STD_LOGIC;
signal broadcast_valid, combine_valid : STD_LOGIC_VECTOR (1 downto 0);
signal s_t_in_valid, s_t_out_valid, gn_t_1_valid, gp_t_1_valid, gn_s_t_in_valid, gp_s_t_in_valid, gn_s_t_out_valid, gp_s_t_out_valid : STD_LOGIC;
signal gn_s_t_drift_in_valid, gp_s_t_drift_in_valid, gn_s_t_drift_out_valid, gp_s_t_drift_out_valid : STD_LOGIC;
signal max_gn_in_valid, max_gp_in_valid, max_gn_out_valid, max_gp_out_valid, gn_t_valid, gp_t_valid, gn_fifo_in_valid, gp_fifo_in_valid : STD_LOGIC;
signal timestamp_in_valid : STD_LOGIC;
signal gn_s_t_valid, gp_s_t_valid : STD_LOGIC;
signal abnormal_flag_valid : STD_LOGIC;

-- is first control signal
signal is_first : STD_LOGIC_VECTOR (NUM_SENSORS - 1 downto 0) := (others => '1');
signal measurements_valid : STD_LOGIC := '1';

signal gn_t_1_ready_array, gp_t_1_ready_array : STD_LOGIC_VECTOR (NUM_SENSORS - 1 downto 0) := (others => '0');
signal gn_t_ready_array, gp_t_ready_array : STD_LOGIC_VECTOR (NUM_SENSORS - 1 downto 0) := (others => '0');
signal gn_t_1_valid_array, gp_t_1_valid_array : STD_LOGIC_VECTOR (NUM_SENSORS - 1 downto 0) := (others => '0');
signal gn_t_valid_array, gp_t_valid_array : STD_LOGIC_VECTOR (NUM_SENSORS - 1 downto 0) := (others => '0');
signal gn_t_valid_mask, gp_t_valid_mask : STD_LOGIC_VECTOR (NUM_SENSORS - 1 downto 0) := (others => '0');
signal gn_t_1_ready_mask, gp_t_1_ready_mask : STD_LOGIC_VECTOR (NUM_SENSORS - 1 downto 0) := (others => '0');

type g_type is array (NUM_SENSORS - 1 downto 0) of STD_LOGIC_VECTOR (63 downto 0);
signal gn_t_1_array, gp_t_1_array : g_type;

signal gn_s_t_input, gp_s_t_input : STD_LOGIC_VECTOR (63 downto 0);
signal gn_s_t_input_valid, gp_s_t_input_valid : STD_LOGIC;

signal th_valid : STD_LOGIC := '0';

begin
    
    current_sensor_in_ready <= broadcast_ready(0) and broadcast_ready(1);
    
    bypass_current_sensor_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => current_sensor_in_valid,
        s_axis_tready => broadcast_ready(0),
        s_axis_tdata => current_sensor_in_data,
        m_axis_tvalid => combine_valid(1),
        m_axis_tready => combine_ready(1),
        m_axis_tdata => current_sensor_measurement_bypass
    );

    current_sensor_in_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => current_sensor_in_valid,
        s_axis_tready => broadcast_ready(1),
        s_axis_tdata => current_sensor_in_data,
        m_axis_tvalid => current_sensor_measurement_valid,
        m_axis_tready => current_sensor_measurement_ready,
        m_axis_tdata => current_sensor_measurement
    );
    
    previous_sensor_in_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => previous_sensor_in_valid,
        s_axis_tready => previous_sensor_in_ready,
        s_axis_tdata => previous_sensor_in_data,
        m_axis_tvalid => previous_sensor_measurement_valid,
        m_axis_tready => previous_sensor_measurement_ready,
        m_axis_tdata => previous_sensor_measurement 
    );
    
    --s_t_sub_input_ready <= current_sensor_measurement_ready and previous_sensor_measurement_ready;
    --s_t_sub_input_valid <= s_t_sub_input_ready and current_sensor_measurement_valid and previous_sensor_measurement_valid;
    
    measurements_valid <= current_sensor_measurement_valid and previous_sensor_measurement_valid;
    
    process(clk)
        
        function to_string(lvec: in std_logic_vector) return string is
            variable text: string(lvec'length-1 downto 0) := (others => '9');
        begin
            for k in lvec'range loop
                case lvec(k) is
                    when '0' => text(k) := '0';
                    when '1' => text(k) := '1';
                    when 'U' => text(k) := 'U';
                    when 'X' => text(k) := 'X';
                    when 'Z' => text(k) := 'Z';
                    when '-' => text(k) := '-';
                    when others => text(k) := '?';
                end case;
            end loop;
            
            return text;
        end function;
    
    begin
        if rising_edge(clk) then
            if previous_sensor_in_valid = '1' and current_sensor_in_valid = '1' then
                assert current_sensor_in_data(31 downto 16) = previous_sensor_in_data(31 downto 16)
--                assert current_sensor_measurement(31 downto 16) = previous_sensor_measurement(31 downto 16)
                  report "Ids are not the same... " & to_string(current_sensor_in_data(31 downto 0)) & " " & to_string(previous_sensor_in_data(31 downto 0))
                  severity FAILURE;
            end if;
        end if;
    end process;
    
    s_t_sub : multi_stream_int_adder_subtractor port map (
        aclk => clk,
        s_axis_a_tvalid => current_sensor_measurement_valid,
        s_axis_a_tready => current_sensor_measurement_ready,
        s_axis_a_tdata => current_sensor_measurement,
        s_axis_b_tvalid => previous_sensor_measurement_valid,
        s_axis_b_tready => previous_sensor_measurement_ready,
        s_axis_b_tdata => previous_sensor_measurement,
        s_axis_operation_tvalid => '1',
        s_axis_operation_tready => s_t_op_ready,
        s_axis_operation_tdata => "00000001",
        m_axis_result_tvalid => s_t_in_valid,
        m_axis_result_tready => s_t_in_ready,
        m_axis_result_tdata => s_t_in
    ); 

    s_t_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => s_t_in_valid,
        s_axis_tready => s_t_in_ready,
        s_axis_tdata => s_t_in,
        m_axis_tvalid => s_t_out_valid,
        m_axis_tready => s_t_result_ready,
        m_axis_tdata => s_t_out
    );
    
    s_t_result_ready <= s_t_out_ready;
--    s_t_result_ready <= s_t_out_ready when is_first(to_integer(unsigned(s_t_out(31 downto 16)))) = '0' else '1';
    s_t_result <= s_t_out when is_first(to_integer(unsigned(s_t_out(31 downto 16)))) = '0' else x"00000000" & s_t_out(31 downto 0);
    
    -- pe clock si verificare is first + s_t_out_valid = '1'
    -- is_first = '1' pe reset in acelasi proces
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                is_first <= (others => '1');
            else 
                if s_t_out_valid = '1' and is_first(to_integer(unsigned(s_t_out(31 downto 16)))) = '1' and gp_t_1_ready = '1' and gp_s_t_ready = '1' and gn_t_1_ready = '1' and gn_s_t_ready = '1' then
                    is_first(to_integer(unsigned(s_t_out(31 downto 16)))) <= '0';
                end if;
            end if;
        end if;
    end process;
    
--    gn_fifo_gen : for i in 0 to NUM_SENSORS - 1 generate
--        gn_fifo_buffer : axis_register_slice port map (
--        aresetn => rst,
--        aclk => clk,
--        s_axis_tvalid => gn_t_valid_array(i),
--        s_axis_tready => gn_t_ready_array(i),
--        s_axis_tdata => gn_t,
--        m_axis_tvalid => gn_t_1_valid_array(i),
--        m_axis_tready => gn_t_1_ready_array(i),
--        m_axis_tdata => gn_t_1_array(i) 
--    );
--    end generate gn_fifo_gen;   
    
--    gp_fifo_gen : for i in 0 to NUM_SENSORS - 1 generate
--        gp_fifo_buffer : axis_register_slice port map (
--        aresetn => rst,
--        aclk => clk,
--        s_axis_tvalid => gp_t_valid_array(i),
--        s_axis_tready => gp_t_ready_array(i),
--        s_axis_tdata => gp_t,
--        m_axis_tvalid => gp_t_1_valid_array(i),
--        m_axis_tready => gp_t_1_ready_array(i),
--        m_axis_tdata => gp_t_1_array(i)
--    );
--    end generate gp_fifo_gen;

    gn_fifo_gen : for i in 0 to NUM_SENSORS - 1 generate
        gn_fifo_buffer : axi_register port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => gn_t_valid_array(i),
        s_axis_tready => gn_t_ready_array(i),
        s_axis_tdata => gn_t,
        m_axis_tvalid => gn_t_1_valid_array(i),
        m_axis_tready => gn_t_1_ready_array(i),
        m_axis_tdata => gn_t_1_array(i) 
    );
    end generate gn_fifo_gen;   
    
    gp_fifo_gen : for i in 0 to NUM_SENSORS - 1 generate
        gp_fifo_buffer : axi_register port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => gp_t_valid_array(i),
        s_axis_tready => gp_t_ready_array(i),
        s_axis_tdata => gp_t,
        m_axis_tvalid => gp_t_1_valid_array(i),
        m_axis_tready => gp_t_1_ready_array(i),
        m_axis_tdata => gp_t_1_array(i)
    );
    end generate gp_fifo_gen;
    
    --gn_s_t_sub_input_ready <= gn_t_1_ready and gn_s_t_ready and gn_s_t_op_ready;
    --gn_s_t_sub_input_valid <= gn_s_t_sub_input_ready and gn_t_1_valid and gn_s_t_valid;
    
    s_t_out_ready <= gn_s_t_ready and gp_s_t_ready;
    gn_s_t_valid <= s_t_out_valid;
    gp_s_t_valid <= s_t_out_valid;
    
    gn_s_t_input <= x"00000000" & s_t_result(31 downto 0) when is_first(to_integer(unsigned(s_t_result(31 downto 16)))) = '1' else gn_t_1;
    gn_s_t_input_valid <= '1' when is_first(to_integer(unsigned(s_t_result(31 downto 16)))) = '1' and s_t_out_valid = '1' else gn_t_1_valid;
    
    gn_t_1_ready_mask(0) <= gn_t_1_ready;
    gn_t_1_ready_array <= std_logic_vector(shift_left(unsigned(gn_t_1_ready_mask), to_integer(unsigned(s_t_result(31 downto 16)))));
    gn_t_1_valid <= gn_t_1_valid_array(to_integer(unsigned(s_t_result(31 downto 16))));
    gn_t_1 <= gn_t_1_array(to_integer(unsigned(s_t_result(31 downto 16))));
    
    gp_t_1_ready_mask(0) <= gp_t_1_ready;
    gp_t_1_ready_array <= std_logic_vector(shift_left(unsigned(gp_t_1_ready_mask), to_integer(unsigned(s_t_result(31 downto 16)))));
    gp_t_1_valid <= gp_t_1_valid_array(to_integer(unsigned(s_t_result(31 downto 16))));
    gp_t_1 <= gp_t_1_array(to_integer(unsigned(s_t_result(31 downto 16))));
    
    gn_s_t_sub : multi_stream_int_adder_subtractor port map (
        aclk => clk,
        s_axis_a_tvalid => gn_s_t_input_valid,
        s_axis_a_tready => gn_t_1_ready,
        s_axis_a_tdata => gn_s_t_input,
        s_axis_b_tvalid => gn_s_t_valid,
        s_axis_b_tready => gn_s_t_ready,
        s_axis_b_tdata => s_t_result,
        s_axis_operation_tvalid => '1',
        s_axis_operation_tready => gn_s_t_op_ready,
        s_axis_operation_tdata => "00000001",
        m_axis_result_tvalid => gn_s_t_in_valid,
        m_axis_result_tready => gn_s_t_in_ready,
        m_axis_result_tdata => gn_s_t_in
    ); 
    
    gp_s_t_input <= x"00000000" & s_t_result(31 downto 0) when is_first(to_integer(unsigned(s_t_result(31 downto 16)))) = '1' else gp_t_1;
--    gp_s_t_input <= s_t_result(63 downto 32) & x"00000000" when is_first(to_integer(unsigned(s_t_result(63 downto 32)))) = '1' else gp_t_1_array(to_integer(unsigned(s_t_result(63 downto 32))));
    gp_s_t_input_valid <= '1' when is_first(to_integer(unsigned(s_t_result(31 downto 16)))) = '1' and s_t_out_valid = '1' else gp_t_1_valid;
    
    gp_s_t_add : multi_stream_int_adder_subtractor port map (
        aclk => clk,
        s_axis_a_tvalid => gp_s_t_input_valid,
        s_axis_a_tready => gp_t_1_ready,
        s_axis_a_tdata => gp_s_t_input,
        s_axis_b_tvalid => gp_s_t_valid,
        s_axis_b_tready => gp_s_t_ready,
        s_axis_b_tdata => s_t_result,
        s_axis_operation_tvalid => '1',
        s_axis_operation_tready => gp_s_t_op_ready,
        s_axis_operation_tdata => "00000000",
        m_axis_result_tvalid => gp_s_t_in_valid,
        m_axis_result_tready => gp_s_t_in_ready,
        m_axis_result_tdata => gp_s_t_in
    ); 
    
    
    gn_s_t_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => gn_s_t_in_valid,
        s_axis_tready => gn_s_t_in_ready,
        s_axis_tdata => gn_s_t_in,
        m_axis_tvalid => gn_s_t_out_valid,
        m_axis_tready => gn_s_t_out_ready,
        m_axis_tdata => gn_s_t_out   
    );
    
    gp_s_t_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => gp_s_t_in_valid,
        s_axis_tready => gp_s_t_in_ready,
        s_axis_tdata => gp_s_t_in,
        m_axis_tvalid => gp_s_t_out_valid,
        m_axis_tready => gp_s_t_out_ready,
        m_axis_tdata => gp_s_t_out   
    );
    
    tagged_drift <= drift_data & gn_s_t_out(31 downto 0);
    
    gn_drift_sub : multi_stream_int_adder_subtractor port map (
        aclk => clk,
        s_axis_a_tvalid => gn_s_t_out_valid,
        s_axis_a_tready => gn_s_t_out_ready,
        s_axis_a_tdata => gn_s_t_out,
        s_axis_b_tvalid => drift_valid,
        s_axis_b_tready => gn_drift_ready,
        s_axis_b_tdata => tagged_drift,
        s_axis_operation_tvalid => '1',
        s_axis_operation_tready => gn_s_t_drift_op_ready,
        s_axis_operation_tdata => "00000001",
        m_axis_result_tvalid => gn_s_t_drift_in_valid,
        m_axis_result_tready => gn_s_t_drift_in_ready,
        m_axis_result_tdata => gn_s_t_drift_in
    );
    
    gp_drift_sub : multi_stream_int_adder_subtractor port map (
        aclk => clk,
        s_axis_a_tvalid => gp_s_t_out_valid,
        s_axis_a_tready => gp_s_t_out_ready,
        s_axis_a_tdata => gp_s_t_out,
        s_axis_b_tvalid => drift_valid,
        s_axis_b_tready => gp_drift_ready,
        s_axis_b_tdata => tagged_drift,
        s_axis_operation_tvalid => '1',
        s_axis_operation_tready => gp_s_t_drift_op_ready,
        s_axis_operation_tdata => "00000001",
        m_axis_result_tvalid => gp_s_t_drift_in_valid,
        m_axis_result_tready => gp_s_t_drift_in_ready,
        m_axis_result_tdata => gp_s_t_drift_in
    ); 
    
    drift_ready <= gn_drift_ready and gp_drift_ready;

    gn_s_t_drift_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => gn_s_t_drift_in_valid,
        s_axis_tready => gn_s_t_drift_in_ready,
        s_axis_tdata => gn_s_t_drift_in,
        m_axis_tvalid => gn_s_t_drift_out_valid,
        m_axis_tready => gn_s_t_drift_out_ready,
        m_axis_tdata => gn_s_t_drift_out   
    );
    
    gp_s_t_drift_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => gp_s_t_drift_in_valid,
        s_axis_tready => gp_s_t_drift_in_ready,
        s_axis_tdata => gp_s_t_drift_in,
        m_axis_tvalid => gp_s_t_drift_out_valid,
        m_axis_tready => gp_s_t_drift_out_ready,
        m_axis_tdata => gp_s_t_drift_out   
    );
    
    tagged_zero <= x"00000000" & gn_s_t_drift_out(31 downto 0);
    
    gn_s_t_max : multi_stream_int_max port map (
        aclk => clk,
        a_valid => gn_s_t_drift_out_valid,
        a_ready => gn_s_t_drift_out_ready,
        a_data => gn_s_t_drift_out,
        b_valid => gn_s_t_drift_out_valid,
        b_ready => max_gn_0_ready,
        b_data => tagged_zero,
        max_valid => max_gn_in_valid,
        max_ready => max_gn_in_ready,
        max_data => max_gn_in
    );
    
    gp_s_t_max : multi_stream_int_max port map (
        aclk => clk,
        a_valid => gp_s_t_drift_out_valid,
        a_ready => gp_s_t_drift_out_ready,
        a_data => gp_s_t_drift_out,
        b_valid => gp_s_t_drift_out_valid,
        b_ready => max_gp_0_ready,
        b_data => tagged_zero,
        max_valid => max_gp_in_valid,
        max_ready => max_gp_in_ready,
        max_data => max_gp_in
    );
    
    max_gn_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => max_gn_in_valid,
        s_axis_tready => max_gn_in_ready,
        s_axis_tdata => max_gn_in,
        m_axis_tvalid => max_gn_out_valid,
        m_axis_tready => max_gn_out_ready,
        m_axis_tdata => max_gn_out    
    );
    
    max_gp_fifo_buffer : fifo16x64 port map (
        s_axis_aresetn => rst,
        s_axis_aclk => clk,
        s_axis_tvalid => max_gp_in_valid,
        s_axis_tready => max_gp_in_ready,
        s_axis_tdata => max_gp_in,
        m_axis_tvalid => max_gp_out_valid,
        m_axis_tready => max_gp_out_ready,
        m_axis_tdata => max_gp_out    
    );
    
    th_valid <= threshold_valid and max_gn_out_valid and max_gp_out_valid;
    
    threshold_exceeding_checker : multi_stream_int_threshold_exceeding_detector port map (
        aclk => clk,
        gp_in_valid => max_gp_out_valid,
        gp_in_ready => max_gp_out_ready,
        gp_in_data => max_gp_out,
        gn_in_valid => max_gn_out_valid,
        gn_in_ready => max_gn_out_ready,
        gn_in_data => max_gn_out,
        th_valid => th_valid,
        th_ready => threshold_ready,
        th_data => threshold_data,
        abnormal_valid => combine_valid(0),
        abnormal_ready => combine_ready(0),
        abnormal_data => combined_data(8),
        gp_out_valid => gp_t_valid,
        gp_out_ready => gp_t_ready,
        gp_out_data => gp_t,
        gn_out_valid => gn_t_valid,
        gn_out_ready => gn_t_ready,
        gn_out_data => gn_t
    );
    
    labeled_data <= combined_data;
    
    gn_t_valid_mask(0) <= gn_t_valid;
    gn_t_valid_array <= std_logic_vector(shift_left(unsigned(gn_t_valid_mask), to_integer(unsigned(gn_t(31 downto 16)))));
    gn_t_ready <= gn_t_ready_array(to_integer(unsigned(gn_t(31 downto 16))));
    
    gp_t_valid_mask(0) <= gp_t_valid;
    gp_t_valid_array <= std_logic_vector(shift_left(unsigned(gp_t_valid_mask), to_integer(unsigned(gp_t(31 downto 16)))));
    gp_t_ready <= gp_t_ready_array(to_integer(unsigned(gp_t(31 downto 16))));
    timestamp_valid <= combine_valid(0) and combine_valid(1);


    combined_data(63 downto 9) <= current_sensor_measurement_bypass(63 downto 9);
    combined_data(7 downto 0) <= (others => '0');
    
    combine_ready(0) <= labeled_data_ready;
    combine_ready(1) <= labeled_data_ready and combine_valid(0);
    
    labeled_data_valid <= combine_valid(0) and combine_valid(1);
    
    timestamp_counter : process(clk)
    begin
        if rising_edge(clk) then
            if combine_valid(0) = '1' then
                timestamp_i <= timestamp_i + 1;
            end if;
        end if;
    end process timestamp_counter;
    
    timestamp_data <= timestamp_i;

end Structural;
