--------------------------------------------------------
-- Copyright (C) 2021 Simon Michael Laube under AGPLv3
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
library ieee_proposed;

architecture LS_lin_beh of approx_root_engine is
  type coeff_t is array (0 to 9) of std_logic_vector(19 downto 0);
  constant coeff : coeff_t := -- fp factor is 2^13
  ("00001000100110100010", -- segment 1, c0
  "00000000000110010111",  -- segment 1, c1
  "00100111000111000111",  -- segment 2, c0
  "00000000000001011111",  -- segment 2, c1
  "01011110110100000100",  -- segment 3, c0
  "00000000000000101001",  -- segment 3, c1
  "10011001111011011111",  -- segment 4, c0
  "00000000000000011010",  -- segment 4, c1
  "11011001101100001000",  -- segment 5, c0
  "00000000000000010010"); -- segment 5, c1
  
  

begin
  -- sample & convert input to 20bit
  process(clk)
      variable c0: unsigned(39 downto 0); --std_logic_vector(39 downto 0);
      variable c1: unsigned(19 downto 0); --std_logic_vector(19 downto 0);
      variable c1x: unsigned(39 downto 0); --std_logic_vector(39 downto 0);
      variable tmpinp: unsigned(19 downto 0);
      variable tmpout: unsigned(39 downto 0); --std_logic_vector(39 downto 0);
  begin
    if(clk'event and clk='1') then
      if(en_read='1') then
        -- set coefficients according to segment
        tmpinp:=resize(unsigned(input),20);
        if(tmpinp<402) then
         c0:=resize(unsigned(coeff(0)),40);
         c1:=unsigned(coeff(1));
        elsif(tmpinp<4096) then
         c0:=resize(unsigned(coeff(2)),40);
         c1:=unsigned(coeff(3));
        elsif(tmpinp<16384) then
         c0:=resize(unsigned(coeff(4)),40);
         c1:=unsigned(coeff(5));
        elsif(tmpinp<32768) then
         c0:=resize(unsigned(coeff(6)),40);
         c1:=unsigned(coeff(7));
        else
         c0:=resize(unsigned(coeff(8)),40);
         c1:=unsigned(coeff(9));
        end if;
        
        -- Calculate  LS approx   
        -- c1*x
        c1x:=c1*tmpinp;
        -- c0 + c1*x
        tmpout:= c0+c1x;
        -- set output
        output<=std_logic_vector(tmpout(20 downto 13));
        en_write<='1';
      else
        en_write<='0';
      end if;
    end if;
  end process;

end LS_lin_beh;

architecture LS_sqr_beh of approx_root_engine is
  type coeff_t is array (0 to 14) of std_logic_vector(31 downto 0);
  constant coeff : coeff_t := -- fp factor is 2^28
  ("00101100100110000001011001011011", -- segment 1, c0
  "00000001010111000001011011000101",  -- segment 1, c1
  "00000000000000001000111110100110",  -- segment 1, c2
  "11011100001110001011100111010110",  -- segment 2, c0
  "00000000010011001111011111000110",  -- segment 2, c1
  "00000000000000000000000110111011",  -- segment 2, c2
  "00000000000000000000001100111101",  -- segment 3, c0
  "00000000001111011001101000110000",  -- segment 3, c1
  "00000000000000000000000001111101",  -- segment 3, c2
  "00000000000000000000000011010110",  -- segment 4, c0
  "00000000001001110111100111111110",  -- segment 4, c1
  "00000000000000000000000000100010",  -- segment 4, c2
  "00000000000000000000000001001011",  -- segment 5, c0
  "00000000000110111110101000000011",  -- segment 5, c1
  "00000000000000000000000000001100"); -- segment 5, c2

begin
  process(clk)
    variable c0: unsigned(63 downto 0);
    variable c1: unsigned(31 downto 0);
    variable c2: unsigned(63 downto 0);
    variable c1x: unsigned(63 downto 0);
    variable c0c1x: unsigned(127 downto 0);
    variable xx:unsigned(63 downto 0);
    variable c2xx: unsigned(127 downto 0);
    variable tmpout: unsigned(127 downto 0);
    variable tmpinp: unsigned(31 downto 0);
    variable inv_clk: std_logic;
  begin
    if(clk'event and clk='1') then
      if(en_read='1') then
        -- set coefficients according to segment
        tmpinp:=resize(unsigned(input),32);
        if(tmpinp<256) then
            c0:=resize(unsigned(coeff(0)),64);
            c1:=unsigned(coeff(1));
            c2:=resize(unsigned(coeff(2)),64);
        elsif(tmpinp<5500) then
            c0:=resize(unsigned(coeff(3)),64);
            c1:=unsigned(coeff(4));
            c2:=resize(unsigned(coeff(5)),64);
        elsif(tmpinp<16000) then
            c0:=resize(unsigned(coeff(6)),64);
            c1:=unsigned(coeff(7));
            c2:=resize(unsigned(coeff(8)),64);
        elsif(tmpinp<34000) then
            c0:=resize(unsigned(coeff(9)),64);
            c1:=unsigned(coeff(10));
            c2:=resize(unsigned(coeff(11)),64);
        else
            c0:=resize(unsigned(coeff(12)),64);
            c1:=unsigned(coeff(13));
            c2:=resize(unsigned(coeff(14)),64);
        end if; 
        -- Calculate LS approx
        -- x^2
        xx:=tmpinp*tmpinp;
        -- c1*x
        c1x:=c1*tmpinp;
        -- c2*x^2
        c2xx:=c2*xx;
        -- c0+c1*x
        c0c1x:=resize(c0+c1x,128);
        -- y=c0 + c1*x - c2*x^2
        tmpout:=c0c1x-c2xx;
        -- set output        
        output<=std_logic_vector(tmpout(35 downto 28));        
        en_write<='1';
      else
        en_write<='0';
      end if;
    end if;
  end process;
end LS_sqr_beh;
