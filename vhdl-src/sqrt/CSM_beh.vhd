--------------------------------------------------------
-- Copyright (C) 2021 Stefan Riesenberger under AGPLv3
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library ieee_proposed;

architecture CSM_beh of approx_root_engine is
-- define singals here
component CSM
port(   x : in  std_logic;
        y : in std_logic;
        b : in  std_logic;
        u : in std_logic;
        bo : out std_logic;
        d : out std_logic);
end component; 
  
constant MAX : integer := 7;
type t_matrix is array (0 to MAX) of std_logic_vector((MAX+2) downto 0);
signal BOA : t_matrix;
signal DA: t_matrix;
signal output_tmp: std_logic_vector(7 downto 0);
begin

    GEN_SQRT_I:
    for I in 0 to MAX generate
        GEN_SQRT_P:
        for P in 0 to I generate
            FIRST_BLOCKS: if I=0 and P=0 generate
                output_tmp(MAX-I)<=not BOA(I)(P);
                EL: CSM port map (x=>input(MAX*2+1), y=>'0', b=>BOA(I)(P+1), u=>BOA(I)(0), bo=>BOA(I)(P), d => DA(I)(P+1));-- shift DA to make the BTW blocks more generic
                DL: CSM port map (x=>input((MAX*2+1)-1), y=>'1', b=>'0', u=>BOA(I)(0), bo=>BOA(I)(P+1), d => DA(I)(P+2));
            end generate FIRST_BLOCKS;

            BTW_BLOCKS: if I/=0 and I /=MAX generate
                FIRST_BIT: if P=0 generate
                    output_tmp(MAX-I)<=not BOA(I)(P);
                    CI: CSM port map (x=>DA(I-1)(P+1), y=>'0', b=>BOA(I)(P+1), u=>'0', bo=>BOA(I)(P), d => open);
                end generate FIRST_BIT;
                
                BTW_BITS: if P /=0 generate
                    BI: CSM port map (x=>DA(I-1)(P+1), y=>output_tmp(MAX-P+1), b=>BOA(I)(P+1), u=>BOA(I)(0), bo=>BOA(I)(P), d => DA(I)(P));--y=>BOA(P-1)(0)
                end generate BTW_BITS;
                
                LAST_TWO_BIT: if P=I generate
                    EL: CSM port map (x=>input((MAX*2+1)-2*I), y=>'0', b=>BOA(I)(P+2), u=>BOA(I)(0), bo=>BOA(I)(P+1), d => DA(I)(P+1));
                    DL: CSM port map (x=>input((MAX*2+1)-2*I-1), y=>'1', b=>'0', u=>BOA(I)(0), bo=>BOA(I)(P+2), d => DA(I)(P+2));
                end generate LAST_TWO_BIT;
            end generate BTW_BLOCKS;
        
            LAST_BLOCK: if I=MAX generate
                FIRST_BIT: if P=0 generate
                    output_tmp(MAX-I)<=not BOA(I)(P);
                    CI: CSM port map (x=>DA(I-1)(P+1), y=>'0', b=>BOA(I)(P+1), u=>'0', bo=>BOA(I)(P), d => open);
                end generate FIRST_BIT;
                
                BTW_BITS: if P /=0 generate
                    BI: CSM port map (x=>DA(I-1)(P+1), y=>output_tmp(MAX-P+1), b=>BOA(I)(P+1), u=>'0', bo=>BOA(I)(P), d => open);--y=>BOA(P-1)(0)
                end generate BTW_BITS;
                
                LAST_TWO_BIT: if P=I generate
                    EL: CSM port map (x=>input(1), y=>'0', b=>BOA(I)(P+2), u=>'0', bo=>BOA(I)(P+1), d => open);
                    DL: CSM port map (x=>input(0), y=>'1', b=>'0', u=>'0', bo=>BOA(I)(P+2), d => open);
                end generate LAST_TWO_BIT;
            end generate LAST_BLOCK;
        end generate GEN_SQRT_P;
    end generate GEN_SQRT_I;

process(clk)
-- define variables for the process here
begin
if(clk'event and clk = '1') then -- rising clock edge
    if(en_read = '1') then -- high level on en to read on rising clock
        output <= output_tmp;
        en_write <= '1';
    else 
        en_write <= '0';               
    end if;  
end if;
end process;

end CSM_beh;
