library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_multi_stream_int_max is
end tb_multi_stream_int_max;

architecture Tb of tb_multi_stream_int_max is

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

constant T : time := 20 ns;

signal clk : STD_LOGIC := '0';

-- data signals
signal a, b, max : STD_LOGIC_VECTOR (63 downto 0);

-- ready signals
signal a_ready, b_ready, max_ready : STD_LOGIC := '0';

-- valid signals
signal a_valid, b_valid, max_valid : STD_LOGIC := '0';

begin

    clk <= not clk after T / 2;
    
    DUT : multi_stream_int_max port map (
        aclk => clk, 
        a_valid => a_valid,
        a_ready => a_ready,
        a_data => a,
        b_valid => b_valid, 
        b_ready => b_ready,
        b_data => b,
        max_valid => max_valid,
        max_ready => max_ready,
        max_data => max
    );
    
    a <= x"0000001E" & x"00020000"; 
    b <= x"00000015" & x"00020000", x"0000001F" & x"00020000" after 8 * T; 
    
    a_valid <= not a_valid after T;
    b_valid <= not b_valid after 2 * T;
    max_ready <= not max_ready after 4 * T;
end Tb;
