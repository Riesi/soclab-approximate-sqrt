--------------------------------------------------------
-- Copyright (C) 2021 Christoph Buchner under AGPLv3
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity baud_clk_gen is
     Generic(
        prescaler: integer := 16384  ); -- 16384 = 2^14
     Port (
        en : in std_logic; 
        clk : in std_logic;
        baud_clk : out std_logic);
end baud_clk_gen;

architecture Behavioral of baud_clk_gen is
--attributes 
    
    signal out_clk : std_logic := '0';
begin
    -- set output
    baud_clk <= out_clk;
    
    --calculate output
    baud_clk_gen: process(clk,en)
    -- count variable to enable prescaling 
    variable count:integer:=0;
    begin
        
        -- update on rising edge if enabled
        if (clk'event and clk = '1') then 
            if en = '0'  then 
            -- reset on falling en edge
                count := 0;
            elsif en = '1' then
                count := count + 1;
                --if integer overflow toggle clock
                if count = (prescaler+1)/2 then
                    count := 0; 
                    out_clk <= not out_clk; 
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
