library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity hexcon is
port( 
	  
	  input:in std_logic_vector(3 downto 0);
	  output:out std_logic_vector(6 downto 0)
);
end hexcon;
--------------------------------------------------------------
architecture hex_arc of hexcon is
begin                                   

with input(3 downto 0) select
-- output <= "0111111" WHEN "0000",
		-- "0000110" when "0001",
		-- "1011011" when "0010",
		-- "1001111" when "0011",
		-- "1100110" when "0100",
		-- "1101101" when "0101",
		-- "1111101" when "0110",
		-- "1000111" when "0111",
		-- "1111111" when "1000",
		-- "1100111" when "1001",
		-- "1110111" when "1010",
		-- "1111100" when "1011",
		-- "0111001" when "1100",
		-- "1011110" when "1101",
		-- "1111001" when "1110",
		-- "1110001" when "1111",
		-- unaffected when others;
		
	output <= "1000000" WHEN "0000",
		"1111001" when "0001",
		"0100100" when "0010",
		"0110000" when "0011",
		"0011001" when "0100",
		"0010010" when "0101",
		"0000010" when "0110",
		"1111000" when "0111",
		"0000000" when "1000",
		"0011000" when "1001",
		"0001000" when "1010",
		"0000011" when "1011",
		"1000110" when "1100",
		"0100001" when "1101",
		"0000110" when "1110",
		"0001110" when "1111",
		unaffected when others;

end hex_arc;