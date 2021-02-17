library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use STD.textio.all;

entity testbench is
end entity;

architecture beh of testbench is
component approx_root_engine is
    port( clk      : in std_logic;
          en_read  : in std_logic;
          input    : in  std_logic_vector(15 downto 0);
          en_write : out std_logic;
          output   : out std_logic_vector(7 downto 0)
     );
end component;
signal s_clk,s_en_read,s_en_write :std_logic :='0';
signal s_input:std_logic_vector(15 downto 0);
signal s_output:std_logic_vector(7 downto 0);

 file file_RESULTS : text;
begin

DUT: approx_root_engine
port map(s_clk,s_en_read,s_input,s_en_write,s_output);

-- clocking process
process
 variable outline: line;
 variable ivec: std_logic_vector(15 downto 0);
begin
  file_open(file_RESULTS, "sim_results.txt", write_mode);
    s_en_read <= '1';
  for i in 0 to 65535 loop
    report "The value of 'i' is " & integer'image(i);
    ivec:=std_logic_vector(to_unsigned(i,16));
    s_clk<='0';
    wait for 5 ns;
    s_input<=ivec;
    wait for 5 ns;
    s_clk<='1';
    wait for 10 ns;
    write(outline,to_integer(unsigned(s_output)));
    writeline(file_RESULTS, outline);
  end loop;

file_close(file_RESULTS);
wait;
end process;

end architecture;
