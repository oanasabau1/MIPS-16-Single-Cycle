library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
Port (clk : in STD_LOGIC;
      digits : in STD_LOGIC_VECTOR(15 downto 0);
      an : out STD_LOGIC_VECTOR (3 downto 0);
      cat : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is

signal digit : STD_LOGIC_VECTOR(3 downto 0);
signal sel : STD_LOGIC_VECTOR(1 downto 0);
signal cnt: STD_LOGIC_VECTOR(15 downto 0):=x"0000";

begin

counter: process(clk)
begin
if rising_edge(clk) then
cnt<= cnt + 1;
end if;
end process;

sel <= cnt(15 downto 14);

MuxDigits: process(sel)
begin
case sel is
when "00" => digit<= digits(3 downto 0);
when "01" => digit<= digits(7 downto 4);
when "10" => digit<= digits(11 downto 8);
when "11" => digit<= digits(15 downto 12);
end case;
end process;

MuxAnod: process(sel)
begin
case sel is
when "00" => an<= "1110";
when "01" => an<= "1101";
when "10" => an<= "1011";
when "11" => an<= "0111";
end case;
end process;

HEX_TO_7_DISP: process(digit)
begin
case digit is
when "0000" => cat <="1000000"; --0
when "0001" => cat <="1111001"; --1
when "0010" => cat <="0100100"; --2
when "0011" => cat <="0110000"; --3
when "0100" => cat <="0011001"; --4
when "0101" => cat <="0010010"; --5
when "0110" => cat <="0000010"; --6 
when "0111" => cat <="1111000"; --7
when "1000" => cat <="0000000"; --8
when "1001" => cat <="0010000"; --9
when "1010" => cat <="0001000"; --A
when "1011" => cat <="0000011"; --b
when "1100" => cat <="1000110"; --C
when "1101" => cat <="0100001"; --d
when "1110" => cat <="0000110"; --E
when "1111" => cat <="0001110"; --F
end case;
end process;

end Behavioral;