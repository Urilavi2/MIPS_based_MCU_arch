--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
--use ieee.numeric_std.all;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Zero_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC;
			shamt_extend    : IN   STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END Execute;

ARCHITECTURE behavior OF Execute IS


component shifter is
	GENERIC (n : INTEGER := 32;
			 k : INTEGER := 5;
			 m : integer := 16	); -- m=2^(k-1)
	port ( inp: in STD_LOGIC_VECTOR (n-1 downto 0);
			sel: in STD_LOGIC_VECTOR (n-1 downto 0);
			control: in STD_LOGIC;
			res: out STD_LOGIC_VECTOR (n-1 downto 0);
			c_out: OUT STD_LOGIC);
			
end component;


SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
signal shifter_res          : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal temp,shift_sel       : std_logic := '0';
SIGNAL mul_res 		        : STD_LOGIC_VECTOR( 63 DOWNTO 0 );

BEGIN

	Shft : shifter generic map (32,5,16) port map (Binput, Ainput, shift_sel, shifter_res, temp);

	Ainput <= shamt_extend when (ALUOp(2 downto 0) = "0010" and (Function_opcode(5 downto 0) = "000000" or Function_opcode(5 downto 0) = "000010"))
				else Read_data_1;
						-- ALU input mux
	Binput <= Read_data_2 
		WHEN ( ALUSrc = "00") 
  		ELSE  Sign_extend( 31 DOWNTO 0 ) WHEN ( ALUSrc = "01") ELSE Zero_extend( 31 DOWNTO 0 );
						-- Generate ALU control bits
	--ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );
	--ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );
	--ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
	
	PROCESS ( ALUOp , Function_opcode )
		BEGIN
		CASE ALUOp IS
		WHEN "0000" 	=>	ALU_ctl <= "0010";
		WHEN "0001" 	=>	ALU_ctl <= "0110";
		WHEN "0010" 	=>	
			if Function_opcode( 1 ) = '0' then
				shift_sel <= '0';
			else
				shift_sel <= '1';
			end if;
			if Function_opcode(5 downto 2) = "0000" then
				ALU_ctl(0) <= '1';
			else
				ALU_ctl(0) <= (Function_opcode(0) OR Function_opcode(3)) AND ALUOp(1);
			end if;
			if Function_opcode(5 downto 2) = "0000" then
				--ALU_ctl( 1 ) <= not Function_opcode( 1 );
				ALU_ctl( 1 ) <= '1';
			else
				ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) ) ;
			end if;
			if Function_opcode(5 downto 2) = "0000" then
				--ALU_ctl( 2 ) <= Function_opcode( 1 );
				ALU_ctl( 2 ) <= '0';
			else
				ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
			end if;
			ALU_ctl( 3 ) <= '0';
			
		WHEN "0011" 	=> ALU_ctl <= "0000";
		WHEN "0100" 	=> ALU_ctl <= "0001";
		WHEN "0101" 	=> ALU_ctl <= "0100";
		WHEN "0110" 	=> ALU_ctl <= "0101";
		--WHEN "111" 	=> ALU_ctl <= "101";
		WHEN "1000" 	=> ALU_ctl <= "1000";
		WHEN "1001" 	=> ALU_ctl <= "0111";
 	 	WHEN OTHERS	=> ALU_ctl <= "0000";
  	END CASE;
  END PROCESS;
	
	mul_res <= Ainput * Binput;
	
						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) 
		WHEN  ALU_ctl = "0111" 
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );

PROCESS ( ALU_ctl, Ainput, Binput, shifter_res , mul_res )
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ALUresult = A_input SLL B_input
 	 	WHEN "0011" 	=>	ALU_output_mux  <= shifter_res;
		--WHEN "011" 	=>	ALU_output_mux  <= X"00000000";
						-- ALU performs ALUresult = A_input XOR B_input
 	 	WHEN "0100" 	=>	ALU_output_mux 	<= Ainput XOR Binput; 
						-- ALU performs ALUresult = A_input SRL B_input
 	 	WHEN "0101" 	=>	ALU_output_mux  <= mul_res(31 downto 0);
		--WHEN "101" 	=>	ALU_output_mux  <= X"00000000";
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
		WHEN "1000" 	=>	ALU_output_mux 	<= Binput(15 downto 0) & X"0000";
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;

