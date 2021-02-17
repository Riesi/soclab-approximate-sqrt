--------------------------------------------------------
-- Copyright (C) 2021 Christoph Buchner under AGPLv3
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library ieee_proposed;

architecture QUAKE_beh of approx_root_engine is
signal s_edge_enread : std_logic := '0';

begin 
   
    sync: process(clk)
    variable v_in:      unsigned(15 downto 0) := (others => '0'); -- variables to enable bit manipulation
    variable v_exp_in:  unsigned(4 downto 0) := (others => '0');
    variable v_out:     unsigned(15 downto 0) := (others => '0');
    variable v_exp_out: unsigned(4 downto 0) := (others => '0');  
    variable v_delta_exp: integer range 0 to 16;
    
    begin
                    
        if(clk'event and clk = '1') then -- rising clock edge
            if(en_read = '1') then -- high level on en to read on rising clock
                -- read input 
                v_in := unsigned(input);
                
                -- search for exponent 
                if (v_in = to_unsigned(0, input'length)) then 
                    v_exp_in := "00000";
                else            
                    for I in v_in'length -1 downto 0 loop
                        if (v_in(I) = '1') then 
                            v_exp_in := to_unsigned(I + 1, v_exp_in'length);
                            exit;
                        end if;
                    end loop;
                end if;
                -- clear exp bit to get the mantisse
                if v_exp_in(0) = '1' then    
                    v_in(to_integer(v_exp_in) - 1) := '0';
                end if;
                
                -- v_in/2 (v_exp+1)/2
                v_in := shift_right(v_in, 1);
                v_exp_out := v_exp_in + to_unsigned(1, v_exp_in'length);
                v_exp_out := shift_right(v_exp_out, 1);
                
                -- rebase mantisse to new exponent
                v_delta_exp  := to_integer( v_exp_in - v_exp_out);
                v_in         := shift_right(v_in,v_delta_exp);
                
                -- set the bit of the exponent to regain the integer number 
                if v_exp_out /=  to_unsigned(0,v_exp_out'length) then
                    v_in(to_integer(v_exp_out) - 1) := '1';
                end if;
                
                v_out := v_in;
                output  <= std_logic_vector(v_out(7 downto 0));
                en_write <= '1';
            else 
                en_write <= '0';               
            end if;   
        end if;
    end process; 
end QUAKE_beh;
