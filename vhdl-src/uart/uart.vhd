--------------------------------------------------------
-- Copyright (C) 2021 Christoph Buchner under AGPLv3
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.

entity uart is

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
        rx      : in STD_LOGIC;                  -- uart serial data in
        en_read : out std_logic := '0';     -- signalises if new data is available on data_out
        rx_data : out STD_LOGIC_VECTOR (uart_datawidth -1 downto 0); -- parallised  data bit extracted from rx uart
        
        -- send uart data
        tx      : out STD_LOGIC;                 -- uart serial data out
        tx_idle : out std_logic;            -- signalises if new data can be applied to write process 
        en_write: in   std_logic := '0';    -- input rising edge signalise new data opn data_in for tx uart
        tx_data : in STD_LOGIC_VECTOR (uart_datawidth - 1 downto 0)); --input data for tx uart
end uart;

architecture Behavioral of uart is
    --attributes
    --component declaration
    component uart_rx 
    generic(
        clk_rate  : integer := 100e6;
        uart_baud : integer :=9600;
        uart_datawidth : integer := 8;
        uart_stop_bit : integer := 1;
        uart_idle : std_logic := '1';
        uart_parity : parity := even;
        uart_flow : flow_ctr := none --others than non not supported
        );
    Port ( 
        rx      : in std_logic;
        clk     : in std_logic;
        reset   : in std_logic;
        en_read : out  std_logic;
        data    : out STD_LOGIC_VECTOR (uart_datawidth - 1 downto 0));
    end component;
    
    component uart_tx 
    generic(
        clk_rate  : integer := 100e6;
        uart_baud : integer :=9600;
        uart_datawidth : integer := uart_datawidth;
        uart_stop_bit : integer := 1;
        uart_idle : STD_LOGIC := '1';
        uart_parity : parity := even;
        uart_flow : flow_ctr := none --others than non not supported
        );
    Port ( 
        tx      : out STD_LOGIC;
        clk     : in std_logic;
        reset   : in std_logic;
        idle    : out std_logic;
        en_write: in  std_logic := '0';
        data : in std_logic_vector (uart_datawidth - 1 downto 0));
    end component;
   
    --signals
    signal s_clk, s_reset: std_logic :='0';
    signal s_tx, s_tx_idle, s_en_write: std_logic;
    signal s_tx_data: std_logic_vector(uart_datawidth-1 downto 0);
    signal s_rx, s_en_read :std_logic;
    signal s_rx_data: std_logic_vector(uart_datawidth-1 downto 0);
begin
--signal inputs
s_clk   <= clk; 
s_reset <= reset;
s_tx_data   <= tx_data;
s_rx        <= rx;
s_en_write  <= en_write;
--signal outputs
tx        <= s_tx;
tx_idle   <= s_tx_idle;
en_read   <= s_en_read;
rx_data   <= s_rx_data;

-- intatiate components
com_uart_rx : uart_rx
generic map( 
        clk_rate        => clk_rate,
        uart_baud       => uart_baud,
        uart_datawidth  => uart_datawidth,
        uart_stop_bit   => uart_stop_bit,
        uart_idle       => uart_idle,
        uart_parity     => uart_parity,
        uart_flow       => uart_flow )
port map(
        rx          => s_rx,
        clk         => s_clk,
        reset       => s_reset,
        en_read     => s_en_read,
        data        => s_rx_data);
        
com_uart_tx : uart_tx
generic map( 
        clk_rate        => clk_rate,
        uart_baud       => uart_baud,
        uart_datawidth  => uart_datawidth,
        uart_stop_bit   => uart_stop_bit,
        uart_idle       => uart_idle,
        uart_parity     => uart_parity,
        uart_flow       => uart_flow )
port map(
        tx          => s_tx,
        clk         => s_clk,
        reset       => s_reset,
        idle        => s_tx_idle,
        en_write    => s_en_write,
        data        => s_tx_data);
        

        
end Behavioral;
