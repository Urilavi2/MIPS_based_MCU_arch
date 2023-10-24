		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUSrc 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	MemtoReg 	: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
	Jump        : OUT   STD_LOGIC;
	JumpReg     : OUT   STD_LOGIC;
	Function_opcode     : IN    STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	INT_RECIVE			: IN	STD_LOGIC;
	INT_ACK			: OUT	STD_LOGIC;
	jr_reg				: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	K_MUX_CONT		: out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ISR_JUMP		: out STD_LOGIC;
	DONT_CHANGE_PC	: out STD_LOGIC;
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq, Addi , Andi, Ori, Xori, mul, lui, Bne, slti, jump_reg, j, jal,reti	: STD_LOGIC;
	SIGNAL  ACK_CYCLE,int_write : STD_LOGIC_VECTOR(1 downto 0);

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	j           <=  '1'  WHEN  Opcode = "000010"  ELSE '0';
	jal         <=  '1'  WHEN  Opcode = "000011"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
	Bne         <=  '1'  WHEN  Opcode = "000101"  ELSE '0';
	Addi        <=  '1'  WHEN  Opcode = "001000"  ELSE '0';
	slti        <=  '1'  WHEN  Opcode = "001010"  ELSE '0';
	Andi        <=  '1'  WHEN  Opcode = "001100"  ELSE '0';
	Ori         <=  '1'  WHEN  Opcode = "001101"  ELSE '0';
	Xori        <=  '1'  WHEN  Opcode = "001110"  ELSE '0';
	mul         <=  '1'  WHEN  Opcode = "011100"  ELSE '0';
	lui         <=  '1'  WHEN  Opcode = "001111"  ELSE '0';
	jump_reg    <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "001000"  ELSE '0';
	reti        <=  '1'  WHEN  Opcode = "000000" and Function_opcode = "001000" and jr_reg = "11011" ELSE '0';
  	RegDst(0)   <=  R_format OR mul or reti when int_write = "00" else '0';
	RegDst(1)   <=  jal or reti when int_write = "00" else '0';
	Jump        <=  j or jal when int_write = "00" else '0';
 	ALUSrc(0)  	<=  Lw OR Sw OR Addi OR Xori OR Andi OR Ori OR lui OR slti when int_write = "00" else '0';
	ALUSrc(1)  	<=	Xori OR Andi OR Ori when int_write = "00" else '0';--those commands need to have zero extention
	MemtoReg(0) <=  Lw or reti when int_write = "00" else '0';
	MemtoReg(1) <=  jal or reti when int_write = "00" else '0';
  	RegWrite 	<=  R_format OR Lw or Addi OR Xori OR Andi OR Ori OR mul or lui or slti or jal 
					when int_write = "00" else int_write(0) or int_write(1);
  	MemRead 	<=  Lw when int_write = "00" else '0';
   	MemWrite 	<=  Sw when int_write = "00" else '0'; 
 	Branch(0)   <=  Beq when int_write = "00" else '0';
	Branch(1)   <=  Bne when int_write = "00" else '0';
	ALUOp( 3 ) 	<=  lui or slti when int_write = "00" else '0';
	ALUOp( 2 ) 	<=  Ori or Xori or mul when int_write = "00" else '0';
	ALUOp( 1 ) 	<=  R_format or Andi or mul when int_write = "00" else '0';
	ALUOp( 0 ) 	<=  Beq or Xori or Andi or slti when int_write = "00" else '0'; 
	JumpReg     <=  R_format and jump_reg when int_write = "00" else '0';
	
	--ack_cycle = 01 write pc to k1
	--ack_cycle = 10 write 0 to gie(k0) and ack to int cont (write isr address to pc)
	
	process(reset,clock,INT_RECIVE)--process to create a cycle of 1 shifting left in ackcycle when interrupt
		begin
			if reset = '1' then
				ACK_CYCLE <= "00";
			elsif ((clock'event) and (clock = '1')) then
				ACK_CYCLE(0) <= INT_RECIVE AND (not ACK_CYCLE(1));--only when interrupt occured and not in another interrrupt handeling will start
				ACK_CYCLE(1) <= ACK_CYCLE(0);
			end if;
		end process;
	
	K_MUX_CONT(0)  <= ACK_CYCLE(0);
	K_MUX_CONT(1)  <= ACK_CYCLE(1);
	--acknoledge goes down to zero when gie is being reset
	INT_ACK <= not ACK_CYCLE(1);
	--when not 00 disables all control signals (exept the necessary ones for interrupts)
	int_write <= ACK_CYCLE;
	--for pc to jump to the ISR in the case of interrupt
	ISR_JUMP <= ACK_CYCLE(1);
	--for pc to not advance during interrupt
	DONT_CHANGE_PC <= '1' when ACK_CYCLE(0) = '1' or ACK_CYCLE(1) = '1' else '0';
	
	

   END behavior;


