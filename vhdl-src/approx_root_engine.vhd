---------------------------------------
-- Copyright (C) 2021 under AGPLv3 by
-- Christoph Buchner, 
-- Simon Michael Laube, 
-- Stefan Riesenberger
---------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity approx_root_engine is
    port( clk      : in  std_logic;
     	  en_read  : in  std_logic;
          input    : in  std_logic_vector(15 downto 0);
          en_write : out std_logic := '0';
          output   : out std_logic_vector(7 downto 0) := (others =>'0')
     		);
end approx_root_engine;
