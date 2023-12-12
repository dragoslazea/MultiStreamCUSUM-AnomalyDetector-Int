library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_lOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity testbench_2_sensors_id_from_file is
end testbench_2_sensors_id_from_file;

architecture tb of testbench_2_sensors_id_from_file is

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
           abnormal_data : out STD_LOGIC_VECTOR (32 downto 0);
           abnormal_ready : in STD_LOGIC;
           abnormal_valid : out STD_LOGIC;
           
           timestamp_data : out STD_LOGIC_VECTOR (31 downto 0);
           timestamp_ready : in STD_LOGIC;
           timestamp_valid : out STD_LOGIC);
end component;

constant T : time := 20 ns;

signal clk : STD_LOGIC := '0';
signal rst : STD_LOGIC := '0';
signal nrst, prev_nrst : STD_LOGIC := '1';

-- data signals
signal Tt_s1, Tt_1_s1 : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
signal Tt_s2, Tt_1_s2 : STD_LOGIC_VECTOR (63 downto 0) := x"0000000000010000";
signal Tt, Tt_1 : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
signal th, drift, timestamp : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal abnormal : STD_LOGIC_VECTOR (32 downto 0) := (others => '0');

-- ready signals
signal Tt_ready, Tt_1_ready, th_ready, drift_ready, timestamp_ready, abnormal_ready : STD_LOGIC;

-- valid signals
signal Tt_valid, Tt_1_valid, th_valid, drift_valid, timestamp_valid, abnormal_valid : STD_LOGIC;


signal rd_count, wr_count : integer := 0;
signal end_of_reading : std_logic := '0';
signal first : std_logic := '1';

type measurements_type is array (0 to 5000) of std_logic_vector (63 downto 0);
signal measurements : measurements_type := (others => (others => '0'));


begin

    clk <= not clk after T / 2;
    nrst <= '0', '1' after 5 * T;
    
    DUT : multi_stream_int_cumulative_sums_detector port map (
        clk => clk,
        rst => nrst,
        current_sensor_in_data => Tt,
        current_sensor_in_ready => Tt_ready,
        current_sensor_in_valid => Tt_valid,
        previous_sensor_in_data => Tt_1,
        previous_sensor_in_ready => Tt_1_ready,
        previous_sensor_in_valid => Tt_1_valid,
        drift_data => "00000000000000000000010001110001", -- 1137
        drift_ready => drift_ready,
        drift_valid => '1',
        threshold_data => "00000000000000000000010111011100", -- 1500
        threshold_ready => th_ready,
        threshold_valid => '1',
        abnormal_data => abnormal,
        abnormal_ready => abnormal_ready,
        abnormal_valid => abnormal_valid,
        timestamp_data => timestamp,
        timestamp_ready => timestamp_ready,
        timestamp_valid => timestamp_valid
    );

    abnormal_ready <= '1';
    timestamp_ready <= '1';
    
    process (clk)
        file sensors_data : text open read_mode is "1m_vineyard_phy_mod_bin_st01.txt";
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
                    
                    if Tt_ready = '1' and Tt_1_ready = '1' then
                        readline(sensors_data, in_line);
                        
                        read(in_line, lqi);
                        first <= '0';
                        
                        if lqi(31 downto 16) = x"0000" then 
                            Tt_1 <= Tt_s1;
                            Tt <= lqi;
                            Tt_1_s1 <= Tt_s1;
                            Tt_s1 <= lqi;
                        else
                            Tt_1 <= Tt_s2;
                            Tt <= lqi;
                            Tt_1_s2 <= Tt_s2;
                            Tt_s2 <= lqi;
                        end if;
                        
                        measurements(rd_count) <= lqi;
                        rd_count <= rd_count + 1;
                        
                        report "LQI(t - 1) = " & to_string(Tt_1);
                        report "LQI(t) = " & to_string(Tt);
                    
                    end if;   
                else
                    file_close(sensors_data);
                    end_of_reading <= '1';
                end if;
            
            end if;
            prev_nrst <= nrst;
        end if;  
    end process;
    
    Tt_valid <= '1' when Tt_ready = '1' and Tt_1_ready = '1' and first = '0' else '0';
    Tt_1_valid <= '1' when Tt_ready = '1' and Tt_1_ready = '1' and first = '0' else '0';
    th_valid <= '1' when Tt_ready = '1' and Tt_1_ready = '1' and first = '0' else '0';
    drift_valid <= '1' when Tt_ready = '1' and Tt_1_ready = '1' and first = '0' else '0';
    
    process 
        file results : text open write_mode is "C:\IVA\Research\int_cusum_multi_stream\results_1m_vineyard_phy_mod_bin_st01.csv";
        variable out_line : line;
    begin
        wait until rising_edge(clk);
            
        if nrst = '0' then
            wait until rising_edge(nrst);
        end if;
    
        if wr_count <= rd_count then
            if abnormal_valid = '1' then
                write(out_line, to_integer(signed(timestamp)));
                write(out_line, string'(", "));
                write(out_line, measurements(wr_count));
                write(out_line, string'(", "));
                write(out_line, abnormal);
                writeline(results, out_line);
                
                if abnormal(0) = '1' then
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
    
end tb;
