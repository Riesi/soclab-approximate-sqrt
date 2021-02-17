--------------------------------------------------------
-- Copyright (C) 2021 Christoph Buchner under AGPLv3
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity EdgeDetector is
    port (
        clk      :in std_logic;
        d        :in std_logic;
        edge     :out std_logic
    );
end EdgeDetector;
architecture EdgeDetector_rtl of EdgeDetector is
    signal reg1 :std_logic;
    signal reg2 :std_logic;
begin
reg: process(clk)
begin
    if rising_edge(clk) then
        reg1  <= d;
        reg2  <= reg1;
    end if;
end process;
edge <= reg1 and (not reg2);
end EdgeDetector_rtl;
