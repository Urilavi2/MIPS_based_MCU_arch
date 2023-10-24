LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MCU IS

	GENERIC ( 
		modelsim : INTEGER := 0 );
	PORT( --reset,clock								: IN 	STD_LOGIC; 
		clock								: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC_EN                               : IN 	STD_LOGIC;
		PC									: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
     	Instruction_out						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		LEDS						 		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		HEX_0, HEX_1, HEX_2, HEX_3, HEX_4,HEX_5 : OUT 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
		SW_IN 								: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		KEY_0, KEY_1, KEY_2, KEY_3 			: IN 	STD_LOGIC;
		PWM									: OUT   STD_LOGIC);
END 	MCU;

ARCHITECTURE MCU_ARC OF MCU IS



component MIPS IS

	GENERIC ( 
		modelsim : INTEGER := 0 );
	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC_EN							: IN    STD_LOGIC;
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
END component;


component basic_timer IS
	PORT(	clock		 	: IN 	STD_LOGIC;
			reset		 	: IN 	STD_LOGIC;
			address		 	: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			DB		 		: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead 		: IN 	STD_LOGIC;
			MemWrite 		: IN 	STD_LOGIC;
			BTIFG 			: OUT 	STD_LOGIC;
			PWM				: OUT 	STD_LOGIC);
END component;


component  GPIO IS
	PORT(	clock		 	: IN 	STD_LOGIC;
			reset		 	: IN 	STD_LOGIC; 
			address		 	: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 ); --bits 11,4,3,2,0
			DB		 	: INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			MemRead 		: IN 	STD_LOGIC;
			MemWrite 		: IN 	STD_LOGIC;
			PORT_LEDR		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX0		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX1		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX2		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX3		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX4		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX5		: OUT 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			IO_ADRESS_DIFFER :IN 	STD_LOGIC;
			PORT_SW		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
END component;


component  Int_con IS
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
		
END component;


component hexcon is
port( 
	  
	  input:in std_logic_vector(3 downto 0);
	  output:out std_logic_vector(6 downto 0)
);
end component;

	SIGNAL AB : STD_LOGIC_VECTOR( 11 DOWNTO 0 );
	SIGNAL DB : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL MemWrite,MemRead : STD_LOGIC;
	signal Address_GPIO : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL HEX0_TEMP,HEX1_TEMP,HEX2_TEMP,HEX3_TEMP,HEX4_TEMP,HEX5_TEMP : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL Address_TIMER : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL BTIFG : STD_LOGIC;
	SIGNAL BUTTON_0,BUTTON_1, BUTTON_2, BUTTON_3 : STD_LOGIC;
	SIGNAL int_address : STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	SIGNAL GIE,INT_ACK,INT_RECIVE : STD_LOGIC;
	signal reset : STD_LOGIC;
	
BEGIN

	MIPS_CORE : MIPS
    GENERIC MAP ( modelsim )
	PORT MAP (	reset				=> reset,
				clock				=> clock,
				PC_EN				=> PC_EN,
				PC					=> PC,
				DB					=> DB,
				AB					=> AB,
				Instruction_out		=> Instruction_out,
				MemRead_out			=> MemRead,
				Memwrite_out		=> MemWrite,
				GIE					=> GIE,
				INT_ACK 			=> INT_ACK,
				INT_RECIVE 			=> INT_RECIVE
				);
				
	IO_CONT : GPIO
	PORT MAP (
				clock				=> clock,				
				reset		 		=> reset,
				address		 		=> Address_GPIO,
				DB		 			=> DB,
				MemRead 			=> MemRead,
				MemWrite 			=> MemWrite,
				PORT_LEDR			=> LEDS,
				PORT_HEX0			=> HEX0_TEMP,
				PORT_HEX1			=> HEX1_TEMP,
				PORT_HEX2			=> HEX2_TEMP,
				PORT_HEX3			=> HEX3_TEMP,
				PORT_HEX4			=> HEX4_TEMP,
				PORT_HEX5			=> HEX5_TEMP,
				IO_ADRESS_DIFFER	=> AB(5),
				PORT_SW				=> SW_IN);
				
				
	BASICTIMER : basic_timer
	PORT MAP (
				clock				=> clock,
				reset		 		=> reset,
				address		 		=> Address_TIMER,
				DB		 			=> DB,
				MemRead 			=> MemRead,
				MemWrite 			=> MemWrite,
				BTIFG               => BTIFG,
				PWM					=> PWM);
				
				
	INTERRUPT_CONT : Int_con
	PORT MAP (	clock	 			=> clock,
				PC_EN				=> PC_EN,
				reset_outer_signals	 		=> reset,
				address		 		=> int_address, -- a11,a5,a3-a0
				DB		 			=> DB,
				MemRead 			=> MemRead,
				MemWrite 			=> MemWrite,
				--IRQ	 				=> (0 => '0', 1 => '0', 2 => BTIFG, 3 => BUTTON_1, 4 => BUTTON_2,
				--5 => BUTTON_3, 6 => '0', 7 => '0'),
				IRQ(0)				=> '0',
				IRQ(1)				=> '0',
				IRQ(2)				=> BTIFG,
				IRQ(3)				=> BUTTON_1,
				IRQ(4)				=> BUTTON_2,
				IRQ(5)				=> BUTTON_3,
				IRQ(6)				=> '0',
				IRQ(7)				=> '0',
				RST					=> BUTTON_0,
				GIE	 				=> GIE,
				INT_ACK	 			=> INT_ACK,
				INT_RECIVE			=> INT_RECIVE );	
				
				
	HEX0CONV : hexcon
	PORT MAP (
			input					=> HEX0_TEMP(3 downto 0),
			output					=> HEX_0);
			
	HEX1CONV : hexcon
	PORT MAP (
			input					=> HEX1_TEMP(3 downto 0),
			output					=> HEX_1);
			
	HEX2CONV : hexcon
	PORT MAP (
			input					=> HEX2_TEMP(3 downto 0),
			output					=> HEX_2);
			
	HEX3CONV : hexcon
	PORT MAP (
			input					=> HEX3_TEMP(3 downto 0),
			output					=> HEX_3);
			
	HEX4CONV : hexcon
	PORT MAP (
			input					=> HEX4_TEMP(3 downto 0),
			output					=> HEX_4);
			
	HEX5CONV : hexcon
	PORT MAP (
			input					=> HEX5_TEMP(3 downto 0),
			output					=> HEX_5);


	--pbs are pull up buttons
	BUTTON_0 <= not(KEY_0);
	BUTTON_1 <= not(KEY_1);
	BUTTON_2 <= not(KEY_2);
	BUTTON_3 <= not(KEY_3);
	
	
	--adress bits for every peripherial
	Address_GPIO <= AB(11) & AB(4 downto 2) & AB(0);
	Address_TIMER <= AB(11) & AB(5 downto 2);
	int_address <= AB(11) & AB(5) & AB(3 downto 0);

end MCU_ARC;