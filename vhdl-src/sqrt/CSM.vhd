--------------------------------------------------------
-- Copyright (C) 2021 Stefan Riesenberger under AGPLv3
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CSM is
port(   x : in  std_logic;
        y : in std_logic;
        b : in  std_logic;
        u : in std_logic;
        bo : out std_logic;
        d : out std_logic);
end CSM; 

architecture be of CSM is
signal internal_sig0, internal_sig1, internal_sig2, internal_sig3, internal_sig4 : std_logic;
begin
    internal_sig0 <= (not x) and (not y) and (b);
    internal_sig1 <= (not x) and (y) and (not b);
    internal_sig2 <= (not x) and (y) and (b);
    internal_sig3 <= (x) and (y) and (b);
    internal_sig4 <= (x) and (not y) and (not b);
    bo <= internal_sig0 or internal_sig1 or internal_sig2 or internal_sig3;
    d <= (internal_sig0 and not u) or (internal_sig1 and not u) or (x and u) or internal_sig3 or internal_sig4;
end be;
