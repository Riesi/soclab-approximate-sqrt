---------------------------------------
-- Copyright (C) 2021 under AGPLv3 by
-- Christoph Buchner, 
-- Simon Michael Laube, 
-- Stefan Riesenberger
---------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity env is

Port ( 
        sys_clk     : in std_logic;             -- clk signal with requency of clk_rate
        reset       : in std_logic;
        rx          : in std_logic;
        tx          : out std_logic;
        led_0_reset    : out std_logic;
        received       : out std_logic_vector(16-1 downto 0)
        );
        
end env;

architecture Behavioral of env is
--attributes
-- constants
constant c_datawidth: integer := 16; 
--uart
constant c_clk_rate: integer := 100e6;
constant c_uart_baud: integer := 9600;
constant c_uart_datawidth :integer := 8; 
constant c_uart_stop_bit :integer := 1; 
constant c_uart_idle :std_logic := '1'; 
constant c_uart_parity :parity := even; 
constant c_uart_flow :flow_ctr := none; 

--component declaration
component approx_root_engine is
    port( 
      clk      : in  std_logic;
      en_read  : in  std_logic;
      input    : in  std_logic_vector(16-1 downto 0);
      en_write : out std_logic := '0';
      output   : out std_logic_vector(c_uart_datawidth - 1 downto 0) := (others =>'0')
        );
end component;
component uart is
    generic(
        clk_rate  : integer := 100e6; -- specifies clk rate of input port clk 
        uart_baud : integer :=9600;   -- specifies targetted baud rate
        uart_datawidth : integer := 8;-- specifies datawidth of uart communication
        uart_stop_bit : integer := 1; -- specifies number of stop bits 
        uart_idle : STD_LOGIC := '1'; -- specifies idle state of communication line
        uart_parity : parity := even; -- specifies if there is a parity controll other than even or odd
        uart_flow : flow_ctr := none  -- specifies if there is a flow controll others than non not supported
    );
    Port ( 
        --comon data
        clk     : in std_logic;             -- clk signal with requency of clk_rate
        reset   : in std_logic;             -- reset signal 
        
        -- receive uart data
        rx : in STD_LOGIC;                  -- uart serial data in
        en_read : out std_logic := '0';     -- signalises if new data is available on data_out
        rx_data : out STD_LOGIC_VECTOR (uart_datawidth -1 downto 0); -- parallised  data bit extracted from rx uart
        
        -- send uart data
        tx : out STD_LOGIC;                 -- uart serial data out
        tx_idle : out std_logic;            -- signalises if new data can be applied to write process 
        en_write: in   std_logic := '0';    -- input rising edge signalise new data opn data_in for tx uart
        tx_data : in STD_LOGIC_VECTOR (uart_datawidth - 1 downto 0)); --input data for tx uart
    
end component;

-- signals
signal s_clk, s_reset: std_logic :='0';
signal s_tx, s_tx_idle, s_en_write: std_logic;
signal s_tx_data: std_logic_vector(c_uart_datawidth-1 downto 0);
signal s_rx, s_en_read :std_logic;
signal s_rx_data: std_logic_vector(c_uart_datawidth-1 downto 0); 
signal s_en_read_sqrt : std_logic;
signal s_rx_data_sqrt: std_logic_vector(c_datawidth-1 downto 0) := (others => '0');
begin
-- intatiate components
comp_approx_root_engine : entity work.approx_root_engine (LS_lin_beh) 
port map( 
      clk       =>sys_clk,
      en_read   =>s_en_read_sqrt,
      input     =>s_rx_data_sqrt,
      en_write  =>s_en_write,
      output    =>s_tx_data);
        
comp_uart : uart 
generic map( 
        clk_rate        => c_clk_rate,
        uart_baud       => c_uart_baud,
        uart_datawidth  => c_uart_datawidth,
        uart_stop_bit   => c_uart_stop_bit,
        uart_idle       => c_uart_idle,
        uart_parity     => c_uart_parity,
        uart_flow       => c_uart_flow )
port map(
        clk         => s_clk,
        reset       => s_reset,
        
        tx          => s_tx,
        tx_idle     => s_tx_idle,
        en_write    => s_en_write,
        tx_data     => s_tx_data,
                
        rx          => rx,
        en_read     => s_en_read,
        rx_data     => s_rx_data);    
        
--assign  signals inputs
s_rx  <= rx;
s_clk <= sys_clk; 
s_reset <= reset;
-- assign signal outputs
tx             <= s_tx;
led_0_reset    <= s_reset;

process(s_en_read)
    variable v_low: std_logic_vector(c_uart_datawidth-1 downto 0):=(others=>'0');
    variable v_high:std_logic_vector(c_uart_datawidth-1 downto 0):=(others=>'0');
    variable v_counter: std_logic := '0';
begin 
    
    s_en_read_sqrt <= '0';
    if (s_en_read = '1' and s_en_read'event) then 
        if (v_counter = '0') then 
            v_low := s_rx_data;
        elsif (v_counter = '1')then 
            v_high := s_rx_data;
            received <= (v_high & v_low);
            s_rx_data_sqrt <= (v_high & v_low);
            s_en_read_sqrt <= '1';
        end if; 
        v_counter := not v_counter;    
    end if;
end process;
end Behavioral;
