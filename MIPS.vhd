				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS

	GENERIC ( 
		modelsim : INTEGER := 0 );
	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC_EN							: IN STD_LOGIC;
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		DB							: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		AB							: OUT STD_LOGIC_VECTOR( 11 DOWNTO 0 );
		--ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		--Branch_out, Zero_out, Memwrite_out, 
		--Regwrite_out					: OUT 	STD_LOGIC );
		MemRead_out,MemWrite_out		: OUT 	STD_LOGIC; 
		GIE,INT_ACK						: OUT 	STD_LOGIC; 
		INT_RECIVE						: IN 	STD_LOGIC);
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
		GENERIC (
			modelsim : integer := 0 );
   	     PORT(	PC_EN				: IN STD_LOGIC;
				Instruction			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		Add_result 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        		Branch 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		Zero 				: IN 	STD_LOGIC;
				Jump 				: IN 	STD_LOGIC;
				Jumpi 				: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				JumpReg          	: in    STD_LOGIC;
				read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_out 				: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				ISR_JUMP			: IN    STD_LOGIC;
				ISR_ADDRESS			: IN    STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				DONT_CHANGE_PC		: IN 	STD_LOGIC;
        		clock,reset 		: IN 	STD_LOGIC );
	END COMPONENT; 

	COMPONENT Idecode
 	     PORT(	read_data_1 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data_2 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		Instruction 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		read_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		ALU_result 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		RegWrite  			: IN 	STD_LOGIC;
        		MemtoReg, RegDst 	: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		Sign_extend 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Zero_extend 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				PC_plus_4 			: IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		clock, reset		: IN 	STD_LOGIC;
				shamt_extend        : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				K_MUX_CONT			: in	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				GIE					: OUT   STD_LOGIC);
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	ALUSrc 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	MemtoReg 			: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	RegWrite 			: OUT 	STD_LOGIC;
             	MemRead 			: OUT 	STD_LOGIC;
             	MemWrite 			: OUT 	STD_LOGIC;
             	Branch 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	ALUop 				: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
				Jump        		: OUT   STD_LOGIC;
				JumpReg     		: OUT   STD_LOGIC;
				Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				INT_RECIVE			: IN	STD_LOGIC;
				INT_ACK				: OUT	STD_LOGIC;
				jr_reg				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				K_MUX_CONT			: out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				ISR_JUMP			: out STD_LOGIC;
				DONT_CHANGE_PC		: out STD_LOGIC;
             	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Sign_Extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Zero_extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
               	ALUSrc 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
               	Zero 				: OUT	STD_LOGIC;
               	ALU_Result 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Add_Result 			: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
               	PC_plus_4 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
               	clock, reset		: IN 	STD_LOGIC;
				shamt_extend        : IN   STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
	END COMPONENT;


	COMPONENT dmemory
		GENERIC (
			modelsim : integer := 0 );
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				address 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ADRESS_BUS			: in	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				ACK					: in	STD_LOGIC;
				write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				MemRead, Memwrite 	: IN 	STD_LOGIC;
				clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;
	
	COMPONENT BidirPin
		GENERIC( WIDTH: INTEGER:=16 );
		PORT(   Dout: 	IN 		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				en:		IN 		STD_LOGIC;
				Din:	OUT		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				IOpin: 	INOUT 	STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;

					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Branch 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL RegDst 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL Jump 			: STD_LOGIC;
	SIGNAL Jumpi 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL JumpReg 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  3 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal shamt_extend     : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal Data_From_Bus    : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal en               : STD_LOGIC;
	signal read_data_Temp   : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal K_MUX_CONT		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	signal ack				: STD_LOGIC;
	signal ISR_JUMP, DONT_CHANGE_PC			: STD_LOGIC;
	signal Zero_extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

BEGIN

	BiDirPin1: BidirPin
	GENERIC MAP ( 32 )
	PORT MAP (	Dout 		=> read_data_2,
    	    	en			=> en,
				Din			=> Data_From_Bus,
				IOpin 		=> DB);
				
	
					-- copy important signals to output pins for easy 
					-- display in Simulator
   Instruction_out 	<= Instruction;
   --ALU_result_out 	<= ALU_result;
   --read_data_1_out 	<= read_data_1;
   --read_data_2_out 	<= read_data_2;
   --write_data_out  	<= read_data WHEN MemtoReg(0) = '1' ELSE ALU_result;
   --Branch_out 		<= Branch(0);
   --Zero_out 		<= Zero;
   --RegWrite_out 	<= RegWrite;
   --MemWrite_out 	<= MemWrite;
	MemWrite_out 	<= MemWrite;
	MemRead_out		<= MemRead;
	AB 				<= ALU_Result (11 DOWNTO 0);
   
   
   en	<= '1' WHEN (MemWrite = '1' AND ALU_Result(11) = '1') ELSE '0';
   read_data 		<= read_data_Temp WHEN (ALU_Result(11) = '0' or ack = '0') ELSE Data_From_Bus;
   
   INT_ACK <= ack;
   
					-- connect the 5 MIPS components   
  IFE : Ifetch
	GENERIC MAP (modelsim)
	PORT MAP (	PC_EN			=> PC_EN,
				Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch 			=> Branch,
				Zero 			=> Zero,
				Jump			=> Jump,
				Jumpi			=> Instruction( 7 downto 0),
				JumpReg			=> JumpReg,
				read_data_1 	=> read_data_1,
				PC_out 			=> PC,  
				ISR_JUMP		=> ISR_JUMP,
				ISR_ADDRESS		=> read_data(9 downto 2),
				DONT_CHANGE_PC	=> DONT_CHANGE_PC,
				clock 			=> clock,  
				reset 			=> reset );

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				Sign_extend 	=> Sign_extend,
				Zero_extend		=> Zero_extend,
				PC_plus_4		=> PC_plus_4,
        		clock 			=> clock,  
				reset 			=> reset,
				shamt_extend    => shamt_extend,
				K_MUX_CONT		=> K_MUX_CONT,
				GIE				=> GIE);


   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch 			=> Branch,
				ALUop 			=> ALUop,
				Jump			=> Jump,
				JumpReg			=> JumpReg,
				Function_opcode => Instruction( 5 downto 0 ),
				INT_RECIVE		=> INT_RECIVE,
				INT_ACK			=> ack,
				jr_reg			=> Instruction( 25 downto 21 ),
				K_MUX_CONT		=> K_MUX_CONT,
				ISR_JUMP		=> ISR_JUMP,
				DONT_CHANGE_PC	=> DONT_CHANGE_PC,
                clock 			=> clock,
				reset 			=> reset );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
				Zero_extend		=> Zero_extend,
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset,
				shamt_extend    => shamt_extend );

   MEM:  dmemory
   GENERIC MAP (modelsim)
	PORT MAP (	read_data 		=> read_data_Temp,
				--address 		=> ALU_Result (10 DOWNTO 2),--jump memory address by 4
				address 		=> ALU_Result,
				ADRESS_BUS		=> Data_From_Bus(7 downto 0),
				ACK				=> ack,
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite, 
                clock 			=> clock,  
				reset 			=> reset );
END structure;

