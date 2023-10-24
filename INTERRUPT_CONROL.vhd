LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Int_con IS
	PORT(	clock	 		: IN 	STD_LOGIC;
			PC_EN			: IN    STD_LOGIC;
			reset_outer_signals	 	: OUT 	STD_LOGIC;
			address		 	: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 ); -- a11,a5,a3-a0
			DB		 		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead	 		: IN 	STD_LOGIC;
			MemWrite	 	: IN 	STD_LOGIC;
			IRQ	 			: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
			RST				: IN 	STD_LOGIC;
			GIE	 			: IN 	STD_LOGIC;
			INT_ACK	 		: IN 	STD_LOGIC;
			INT_RECIVE		: OUT 	STD_LOGIC );	
		
END Int_con;


ARCHITECTURE int_con_arc OF Int_con IS

	COMPONENT BidirPin
		GENERIC( WIDTH: INTEGER:=16 );
		PORT(   Dout: 	IN 		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				en:		IN 		STD_LOGIC;
				Din:	OUT		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				IOpin: 	INOUT 	STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL TO_THE_BUS,DataFromBus : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IFG_REGISTER, IE_REGISTER, TYPE_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal CS : STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal BUS_EN : STD_LOGIC;
	SIGNAL IRQ_IMM : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CLEAR_IRQ_IMM : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL IFG_TEMP, TYPE_IN_USE : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL reset_first_latch, reset_second_latch, clr_rst : STD_LOGIC;
	SIGNAL reset : STD_LOGIC;
	SIGNAL PC_EN_REG : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	BEGIN

	BiDirPin_INTERRUPS: BidirPin
	GENERIC MAP ( 32 )
	PORT MAP (	Dout 		=> TO_THE_BUS,
    	    	en			=> BUS_EN,
				Din			=> DataFromBus,
				IOpin 		=> DB );
	
	--pc en register
	PC_EN_REG(0) <= PC_EN;
	PC_EN_REG(1) <= PC_EN;
	PC_EN_REG(2) <= PC_EN;
	PC_EN_REG(3) <= PC_EN;
	PC_EN_REG(4) <= PC_EN;
	PC_EN_REG(5) <= PC_EN;
	PC_EN_REG(6) <= PC_EN;
	PC_EN_REG(7) <= PC_EN;
	
	
	WITH address SELECT
	CS <= "001" WHEN "111100",--IE
		  "010" WHEN "111101",--IFG
		  "100" WHEN "111110",--TYPE
		  "000" WHEN OTHERS;
	
	--the signal trigerring interrupt in mcu
	INT_RECIVE <= ((IFG_REGISTER(0) OR IFG_REGISTER(1) OR IFG_REGISTER(2) OR IFG_REGISTER(3) 
				OR IFG_REGISTER(4) OR IFG_REGISTER(5) OR IFG_REGISTER(6) OR IFG_REGISTER(7)) AND GIE) OR reset_second_latch;
				
	PROCESS(reset, IRQ(0), CLEAR_IRQ_IMM(0))--RX interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(0) <= '0';
			ELSIF CLEAR_IRQ_IMM(0) = '1' THEN
				   IRQ_IMM(0) <= '0';
			ELSIF (( IRQ(0)'EVENT ) AND ( IRQ(0) = '1')) THEN
				   IRQ_IMM(0) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(1), CLEAR_IRQ_IMM(1))--TX interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(1) <= '0';
			ELSIF CLEAR_IRQ_IMM(1) = '1' THEN
				   IRQ_IMM(1) <= '0';
			ELSIF (( IRQ(1)'EVENT ) AND ( IRQ(1) = '1')) THEN
				   IRQ_IMM(1) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(2), CLEAR_IRQ_IMM(2))--BT interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(2) <= '0';
			ELSIF CLEAR_IRQ_IMM(2) = '1' THEN
				   IRQ_IMM(2) <= '0';
			ELSIF (( IRQ(2)'EVENT ) AND ( IRQ(2) = '1')) THEN
				   IRQ_IMM(2) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(3), CLEAR_IRQ_IMM(3))--key1 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(3) <= '0';
			ELSIF CLEAR_IRQ_IMM(3) = '1' THEN
				   IRQ_IMM(3) <= '0';
			ELSIF (( IRQ(3)'EVENT ) AND ( IRQ(3) = '1')) THEN
				   IRQ_IMM(3) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(4), CLEAR_IRQ_IMM(4))--key2 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(4) <= '0';
			ELSIF CLEAR_IRQ_IMM(4) = '1' THEN
				   IRQ_IMM(4) <= '0';
			ELSIF (( IRQ(4)'EVENT ) AND ( IRQ(4) = '1')) THEN
				   IRQ_IMM(4) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(5), CLEAR_IRQ_IMM(5))--key3 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(5) <= '0';
			ELSIF CLEAR_IRQ_IMM(5) = '1' THEN
				   IRQ_IMM(5) <= '0';
			ELSIF (( IRQ(5)'EVENT ) AND ( IRQ(5) = '1')) THEN
				   IRQ_IMM(5) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(6), CLEAR_IRQ_IMM(6))--extra1 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(6) <= '0';
			ELSIF CLEAR_IRQ_IMM(6) = '1' THEN
				   IRQ_IMM(6) <= '0';
			ELSIF (( IRQ(6)'EVENT ) AND ( IRQ(6) = '1')) THEN
				   IRQ_IMM(6) <= '1';
			END IF;
	END PROCESS;
	
	PROCESS(reset, IRQ(7), CLEAR_IRQ_IMM(7))--extra2 interrupt
		BEGIN
			IF reset = '1' THEN
				IRQ_IMM(7) <= '0';
			ELSIF CLEAR_IRQ_IMM(7) = '1' THEN
				   IRQ_IMM(7) <= '0';
			ELSIF (( IRQ(7)'EVENT ) AND ( IRQ(7) = '1')) THEN
				   IRQ_IMM(7) <= '1';
			END IF;
	END PROCESS;
	
	--is determined by interrupt recived
	TYPE_IN_USE(7 DOWNTO 6) <= "00";
	TYPE_IN_USE(1 DOWNTO 0) <= "00";
	TYPE_IN_USE(5 DOWNTO 2) <= "0000" WHEN reset_second_latch = '1' ELSE --reset
						   "0001" WHEN IFG_REGISTER(0) = '1' ELSE --uart error
						   "0010" WHEN IFG_REGISTER(0) = '1' ELSE --uart rx
						   "0011" WHEN IFG_REGISTER(1) = '1' ELSE --uart tx
						   "0100" WHEN IFG_REGISTER(2) = '1' ELSE -- basic timer
						   "0101" WHEN IFG_REGISTER(3) = '1' ELSE --key1
						   "0110" WHEN IFG_REGISTER(4) = '1' ELSE --key2
						   "0111" WHEN IFG_REGISTER(5) = '1' ELSE --key3
							"1000" WHEN IFG_REGISTER(6) = '1' ELSE --int 6
							"1001" WHEN IFG_REGISTER(7) = '1' ELSE --int 7					
						   "0000";
						 
						 
	------------------------
	--clears interuupts
	------------------------
	--cleared both by user and by hardware when interrupt happened
	CLEAR_IRQ_IMM(0) <= '1' WHEN PC_EN = '0' or (((TYPE_OUT(5 DOWNTO 2) = "0001" OR TYPE_OUT(5 DOWNTO 2) = "0010") AND INT_ACK = '0') OR 
	(CS(1) = '1' AND MemWrite = '1' AND DataFromBus(0) = '0')) ELSE '0';
	CLEAR_IRQ_IMM(1) <= '1' WHEN PC_EN = '0' or ((TYPE_OUT(5 DOWNTO 2) = "0011" AND INT_ACK = '0') or
	(CS(1) = '1' AND MemWrite = '1' AND DataFromBus(1) = '0')) ELSE '0';
	CLEAR_IRQ_IMM(2) <= '1' WHEN PC_EN = '0' or ((TYPE_OUT(5 DOWNTO 2) = "0100" AND INT_ACK = '0') OR 
	(CS(1) = '1' AND MemWrite = '1' AND DataFromBus(2) = '0')) ELSE '0';
	
	--cleared only by user
	CLEAR_IRQ_IMM(3) <= '1' WHEN PC_EN = '0' or (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(3) = '0') ELSE '0';--keys are reset by software
	CLEAR_IRQ_IMM(4) <= '1' WHEN PC_EN = '0' or (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(4) = '0') ELSE '0';
	CLEAR_IRQ_IMM(5) <= '1' WHEN PC_EN = '0' or (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(5) = '0') ELSE '0';
	CLEAR_IRQ_IMM(6) <= '1' WHEN PC_EN = '0' or (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(6) = '0') ELSE '0';
	CLEAR_IRQ_IMM(7) <= '1' WHEN PC_EN = '0' or (CS(1) = '1' AND MemWrite = '1' AND DataFromBus(7) = '0') ELSE '0';
	
	
	
						   
	PROCESS (reset, clock) --IE register
	BEGIN
		IF reset = '1' THEN
			IE_REGISTER <= "00000000";
		ELSIF (( clock'EVENT ) AND ( clock = '1')) THEN
			IF (CS(0) = '1' AND MemWrite = '1') THEN
				IE_REGISTER <= DataFromBus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (reset, clock) --TYPE_OUT register
	BEGIN
		IF reset = '1' THEN
			TYPE_OUT <= X"00";
		ELSIF (( clock'EVENT ) AND ( clock = '1')) THEN
				TYPE_OUT <= TYPE_IN_USE;
		END IF;
	END PROCESS;
	
	
	PROCESS(reset, RST, clr_rst)--reset process
		BEGIN
			IF clr_rst = '1' THEN
				   reset_first_latch <= '0';
			ELSIF (( RST'EVENT ) AND ( RST = '1')) THEN
				   reset_first_latch <= '1';
			END IF;
	END PROCESS;
	
	--IFG set only when irq and ie is 1 (and pc enabled)
	IFG_TEMP <= IRQ_IMM AND IE_REGISTER AND PC_EN_REG;
	
	PROCESS (clock) --IFG process
	BEGIN
		IF (( clock'EVENT ) AND ( clock = '1')) THEN -- NOT CLOCK
			reset_second_latch <= reset_first_latch;
			IF reset = '1' THEN
				IFG_REGISTER <= "00000000";
			ELSIF (CS(1) = '1' AND MemWrite = '1') THEN 
				IFG_REGISTER <= DataFromBus(7 DOWNTO 0);
			ELSE 
				IFG_REGISTER <= IFG_TEMP;
			END IF;
		END IF;
	END PROCESS;
	
	--reset clears when second latch is 1
	clr_rst <= '1' WHEN reset_second_latch = '1' ELSE '0';
	--reset everything on first latch
	reset <= '1' WHEN reset_first_latch = '1' ELSE '0';
	reset_outer_signals <= reset;
	
	--bus is written TYPE_OUT when int ack recived or request for register to be read
	BUS_EN <= '1' WHEN (INT_ACK = '0' OR (MemRead = '1' and (CS(0) = '1' or CS(1) = '1' or CS(2) = '1'))) ELSE '0';
	TO_THE_BUS <= X"000000" & TYPE_OUT WHEN (INT_ACK = '0' OR (CS(2) = '1' AND MemRead = '1')) ELSE
			X"000000" & IFG_REGISTER WHEN (CS(1) = '1' AND MemRead = '1') ELSE
			X"000000" & IE_REGISTER WHEN (CS(0) = '1' AND MemRead = '1') ELSE
			(OTHERS => '0');
	
END int_con_arc;