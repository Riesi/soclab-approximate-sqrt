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
entity uart_tx is

    generic(
        clk_rate  : integer := 100e6;
        uart_baud : integer :=9600;
        uart_datawidth : integer := 8;
        uart_stop_bit : integer := 1;
        uart_idle : STD_LOGIC := '1';
        uart_parity : parity := even;
        uart_flow : flow_ctr := none --others than non not supported
    );
    Port ( tx      : out STD_LOGIC;
           clk     : in std_logic;
           reset   : in std_logic;
           idle    : out std_logic:='0';
           en_write: in  std_logic;
           data : in STD_LOGIC_VECTOR (uart_datawidth - 1 downto 0));
    
end uart_tx;

               
architecture Behavioral of uart_tx is
    --attributes
    --signals
    signal s_baud_clk : std_logic := '0';
    signal s_en_baud_clk : std_logic := '0';
    signal s_tx: std_logic := uart_idle;
    signal s_idle: std_logic := '0' ;
    signal s_edge_baud_clk,s_edge_reset,s_edge_en_write : std_logic;
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
    
    tx <= s_tx;
    idle <= s_idle;
    -- asynch reset logic 
    rst_ctr:process(reset) begin
    -- do reset on rising edge
     if(reset = '1' and reset'event) then
    --reset all signals 
        

    end if;  
    end process;
    --edge detectors
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
        
    pos_edge_en_write : EdgeDetector
     port map (
        clk => clk,
        d  => en_write, 
        edge => s_edge_en_write);     
            
    -- generates clk signal with predefined baud rate
    baud_clk_u2 : baud_clk_gen
    generic map (  prescaler => (clk_rate/uart_baud-1))
    port map (
        en  => s_en_baud_clk, 
        clk => clk,
        baud_clk => s_baud_clk);    
  
    -- write procces deserialise and process write data 
    write:process(clk)
    --start+stop+parity+data+end of transmission processing
    variable tx_counter: integer range 0 to (uart_datawidth + uart_stop_bit+2):= 0 ; 
    variable tx_data : std_logic_vector( uart_datawidth -1 downto 0);
    variable tx_parity :std_logic ;
    variable v_idle :std_logic;
    variable v_tx :std_logic;
    variable v_en_baud_clk : std_logic:= '0';
    begin 
        if(clk'event and clk = '1') then 
            --rst cntr for this block 
            if(s_edge_reset = '1') then
                -- reset vars
                v_tx        := uart_idle;
                v_idle      := '1'; 
                tx_counter  := 0;
                tx_data     := (others => '0'); 
                tx_parity   := '0';
                v_en_baud_clk :=  '0';-- also resets the the baud_clk_u1
            end if;            
            -- start signaling on rising edge of en_write
            if (s_edge_en_write = '1') then 
            -- show that we are busy
                v_idle        :=  '0';  
            --start clk
                v_en_baud_clk :=  '1';
            -- read data into buffer
                tx_data := data;
            -- clear dependent vars  
                case uart_parity is 
                    when none => 
                        tx_parity := uart_idle;
                    when even => 
                        tx_parity := tx_data(0);
                    when odd  =>
                        tx_parity := not tx_data(0);
                end case;             
            end if;
            
            --process data        
            if (s_edge_baud_clk = '1') then 
                case tx_counter is 
                    when 0  =>
                        v_tx := not uart_idle;
                        tx_counter := tx_counter +1;
                    when 1 to uart_datawidth => --send data
                        v_tx := tx_data(tx_counter-1);
                        tx_counter := tx_counter +1;
                    when uart_datawidth+1  =>   --send parity
                        v_tx := tx_parity;
                        tx_counter := tx_counter +1;
                    when uart_datawidth+2 to uart_datawidth+1+uart_stop_bit  => --send stopbits
                        v_tx := uart_idle;            
                        tx_counter := tx_counter +1;
                    when others => -- set idle state
                        v_idle := '1';
                        v_en_baud_clk := '0';  
                        tx_counter := 0;  
                        v_tx := uart_idle;            
                end case;
                
            end if;
            s_idle <= v_idle;
            s_tx <= v_tx;
            s_en_baud_clk <= v_en_baud_clk; 
        end if;        
    end process;
   

end Behavioral;
