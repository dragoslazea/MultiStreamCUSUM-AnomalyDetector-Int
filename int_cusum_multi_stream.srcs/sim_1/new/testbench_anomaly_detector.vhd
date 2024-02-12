library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_lOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench_anomaly_detector is
end testbench_anomaly_detector;

architecture Tb of testbench_anomaly_detector is

component multi_stream_cusum_anomaly_detector_top_module is
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
end component;

constant T : time := 20 ns;

signal clk : STD_LOGIC := '0';
signal nrst : STD_LOGIC := '1';

signal t_in : STD_LOGIC_VECTOR (63 downto 0) := x"0000000000000000";
signal th, drift, timestamp : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal labeled_data : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');

signal rd_count, wr_count : integer := 0;
signal end_of_reading : std_logic := '0';
signal is_first : STD_LOGIC := '1';

type measurements_type is array (0 to 5000) of std_logic_vector (63 downto 0);
signal measurements : measurements_type := (others => (others => '0'));

-- ready signals
signal t_in_ready, t_current_ready, t_previous_ready, th_ready, drift_ready, timestamp_ready, labeled_data_ready : STD_LOGIC;

-- valid signals
signal t_in_valid, t_current_valid, t_previous_valid, th_valid, drift_valid, timestamp_valid, labeled_data_valid : STD_LOGIC;

begin

    clk <= not clk after T / 2;
    nrst <= '0', '1' after 5 * T;
    
    DUT : multi_stream_cusum_anomaly_detector_top_module 
    generic map (
        NUM_SENSORS => 7
    )
    port map (
        clk => clk,
        rst => nrst,
        input_value_data => t_in,
        input_value_valid => t_in_valid,
        input_value_ready => t_in_ready,
        drift_data => "00000000000000000000010001110001", -- 1137
        drift_ready => drift_ready,
        drift_valid => '1',
        threshold_data => "00000000000000000000010111011100", -- 1500
        threshold_ready => th_ready,
        threshold_valid => '1',
        labeled_data => labeled_data,
        labeled_data_ready => labeled_data_ready,
        labeled_data_valid => labeled_data_valid,
        timestamp_data => timestamp,
        timestamp_ready => timestamp_ready,
        timestamp_valid => timestamp_valid
    );
    
    labeled_data_ready <= '1';
    timestamp_ready <= '1';
    
    process (clk)
        file sensors_data : text open read_mode is "1m_vineyard_phy_mod_bin_st0123456.txt";
        variable in_line : line;
        
        variable lqi : std_logic_vector(63 downto 0);

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
            if nrst = '1' and end_of_reading = '0' then
                if not endfile(sensors_data) then     
                    
                    if t_in_ready = '1' then
                        readline(sensors_data, in_line);
                        read(in_line, lqi);
                        
                        is_first <= '0';
                    
                        t_in <= lqi;
                        
                        measurements(rd_count) <= t_in;
                        rd_count <= rd_count + 1;
                        
                        report "LQI(t) = " & to_string(t_in);
                    end if;     
                else
                    file_close(sensors_data);
                    end_of_reading <= '1';
                end if;
            end if;
        end if;
    end process;
    
    t_in_valid <= '1' when t_in_ready = '1' and is_first = '0' else '0';
    
    process 
        file results : text open write_mode is "C:\IVA\Research\int_cusum_multi_stream\results_top_module_1m_vineyard_phy_mod_bin_st01_throughput.csv";
        variable out_line : line;
    begin
        wait until rising_edge(clk);
            
        if nrst = '0' then
            wait until rising_edge(nrst);
        end if;
    
        if wr_count <= rd_count then
            if labeled_data_valid = '1' then
                write(out_line, to_integer(signed(timestamp)));
                write(out_line, string'(", "));
                write(out_line, labeled_data);
                writeline(results, out_line);
                
                if labeled_data(8) = '1' then
                    report "abnormal ";
                end if;
                
                wr_count <= wr_count + 1;
            end if;
        else
            file_close(results);
            report "execution finished";
            wait;
        end if;
    end process;


end Tb;
