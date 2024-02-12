library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_lOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench_stream_selector is
end testbench_stream_selector;

architecture tb of testbench_stream_selector is

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

constant T : time := 20 ns;

signal clk : STD_LOGIC := '0';
signal nrst : STD_LOGIC := '1';

signal t_in, t_current, t_previous : STD_LOGIC_VECTOR (63 downto 0) := x"0000000000000000";

signal rd_count, wr_count : integer := 0;
signal end_of_reading : std_logic := '0';

type measurements_type is array (0 to 5000) of std_logic_vector (63 downto 0);
signal measurements : measurements_type := (others => (others => '0'));

-- ready signals
signal t_in_ready, t_current_ready, t_previous_ready : STD_LOGIC;

-- valid signals
signal t_in_valid, t_current_valid, t_previous_valid : STD_LOGIC;

begin

    clk <= not clk after T / 2;
    nrst <= '0', '1' after 5 * T;
    
    st_selector : stream_selector port map(
        clk => clk,
        rst => nrst,
        input_value_data => t_in,
        input_value_valid => t_in_valid,
        input_value_ready => t_in_ready,
        current_sensor_data => t_current,
        current_sensor_valid => t_current_valid,
        current_sensor_ready => t_current_ready,
        previous_sensor_data => t_previous,
        previous_sensor_valid => t_previous_valid,
        previous_sensor_ready => t_previous_ready
    );
    
    t_previous_ready <= '0', '1' after 10 * T, '0' after 20 * T , '1' after 30 * T;
    t_current_ready <= '0', '1' after 20 * T;
    
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
                    
                    if t_in_ready = '1' then
                        readline(sensors_data, in_line);
                        read(in_line, lqi);
                    
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
    
    t_in_valid <= '1' when t_in_ready = '1' else '0';

end tb;
