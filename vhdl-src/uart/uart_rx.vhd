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
--library UNISIM;
--use UNISIM.VComponents.all;
entity uart_rx is
    
    generic(
        clk_rate  : integer := 100e6;
        uart_baud : integer :=9600;
        uart_datawidth : integer := 8;
        uart_stop_bit : integer := 1;
        uart_idle : std_logic := '1';
        uart_parity : parity := even;
        uart_flow : flow_ctr := none --others than non not supported
    );
    Port ( rx      : in std_logic;
           clk     : in std_logic;
           reset   : in std_logic;
           en_read : out  std_logic:='0';
           data: out STD_LOGIC_VECTOR (uart_datawidth - 1 downto 0));
    
end uart_rx;

               
architecture Behavioral of uart_rx is
    --attributes
    --signals
    signal s_baud_clk : std_logic := '0';
    signal s_en_baud_clk : std_logic := '1';
    signal s_en_read: std_logic := '0';
    signal s_edge_reset,s_edge_baud_clk: std_logic;
    --components
    component EdgeDetector is
       port (
          clk      :in std_logic;
          d        :in std_logic;
          edge     :out std_logic
       );
    end component;
    component baud_clk_gen
    Generic(
        prescaler: integer range 0 to 16384  :=9600 ); -- 16384 = 2^14
    PORT(
        en : in std_logic; 
        clk : in std_logic;
        baud_clk : out std_logic);
  end component;
begin
    -- edge detectors
    pos_edge_baud_clk : EdgeDetector
     port map (
        clk => clk,
        d  => s_baud_clk, 
        edge => s_edge_baud_clk);  
          
    pos_edge_reset : EdgeDetector
     port map (
        clk => clk,
        d  => reset, 
        edge => s_edge_reset);   
    -- generates clk signal with predefined baud rate
    baud_clk_u1 : baud_clk_gen
    generic map (  prescaler => (clk_rate/uart_baud-1))
    port map (
        en  => s_en_baud_clk, 
        clk => clk,
        baud_clk => s_baud_clk);    
  
    -- write procces deserialise and process write data 
    write:process(clk)
    --start+stop+parity+data+end of transmission processing
    variable rx_counter: integer range 0 to (uart_datawidth + uart_stop_bit+2):= 0 ; 
    variable rx_data : std_logic_vector( uart_datawidth -1 downto 0);
    variable rx_parity :std_logic ;
    variable v_en_read : std_logic := '0';
    begin 
    if(clk'event and clk ='1') then
        --rst cntr for this block 
        if(s_edge_reset = '1') then
            -- reset vars
          
            rx_counter  := 0;
            rx_data     := (others => '0'); 
            rx_parity   := '0';
            s_en_baud_clk <=  '1';
            
        end if;
        --process data        
        if (s_edge_baud_clk = '1') then 
            case rx_counter is 
                when 0  =>
                    if rx = not (uart_idle) then -- search for startbit
                        v_en_read := '0';
                        rx_counter := rx_counter +1;
                    end if;
                when 1 to uart_datawidth => --receive data
                    rx_data(rx_counter-1) := rx;
                    rx_counter := rx_counter +1;
                when uart_datawidth+1  =>   --receive parity
                    rx_parity := rx;
                    rx_counter := rx_counter +1;
                when uart_datawidth+2 to uart_datawidth+uart_stop_bit+1  => --receive stopbits         
                    rx_counter := rx_counter +1;
                when others => -- set idle state
                    rx_counter := 0;  
                    data <= rx_data;
                    v_en_read := '1';
            end case;
            
            en_read <= v_en_read;
        end if;
    end if;    
    end process;
end Behavioral;
