						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC_VECTOR( 1  DOWNTO 0 );
			RegDst 		: IN 	STD_LOGIC_VECTOR( 1  DOWNTO 0 );
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Zero_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC_plus_4 	: IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock,reset	: IN 	STD_LOGIC;
			shamt_extend: OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			K_MUX_CONT	: in	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			GIE			: OUT   STD_LOGIC);
			
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address, write_register_address2 		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data, write_data2					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	signal shamt                        : STD_LOGIC_VECTOR( 4 DOWNTO 0 );

BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );
	shamt                       <= Instruction( 10 downto 6);
					-- Read Register 1 Operation
	read_data_1 <= register_array( 
			      CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	read_data_2 <= register_array( 
			      CONV_INTEGER( read_register_2_address ) );
					-- Mux for Register Write Address
   write_register_address <= write_register_address_1 
			WHEN RegDst = "01"  ELSE  "11111" WHEN RegDst = "10" ELSE "11010" when RegDst = "11" 
			else write_register_address_0;
					-- Mux to bypass data memory for Rformat instructions
	write_data <= ALU_result( 31 DOWNTO 0 ) 
			WHEN ( MemtoReg = "00" ) ELSE read_data WHEN ( MemtoReg = "01" ) ELSE X"0000000" & B"0001" when MemtoReg = "11"
			ELSE X"00000" & B"00" & PC_plus_4;
					-- Sign Extend 16-bits to 32-bits
    	Sign_extend <= X"0000" & Instruction_immediate_value
		WHEN Instruction_immediate_value(15) = '0'
		ELSE	X"FFFF" & Instruction_immediate_value;
		shamt_extend <= "000000000000000000000000000" & shamt;
		Zero_extend <= X"0000" & Instruction_immediate_value;


	
	write_register_address2 <= "11011" when (K_MUX_CONT = "01") else "11010" when (K_MUX_CONT = "10")
								else write_register_address;
								
	write_data2 <= X"00000" & B"00" & PC_plus_4 when (K_MUX_CONT = "01") else x"00000000" when (K_MUX_CONT = "10")
								else write_data;
	
	


	GIE <= register_array(26)(0);

PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
 			END LOOP;
					-- Write back to register - don't write to register 0
  		ELSIF RegWrite = '1' AND write_register_address2 /= 0 THEN
		      register_array( CONV_INTEGER( write_register_address2)) <= write_data2;
		END IF;
	END PROCESS;
END behavior;


