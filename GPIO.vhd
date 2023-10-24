LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  GPIO IS
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
			IO_ADRESS_DIFFER :IN 	STD_LOGIC;--to distinct io address from other peripherial adresses
			PORT_SW		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
END GPIO;

ARCHITECTURE gpio_arc OF GPIO IS

COMPONENT BidirPin
		GENERIC( WIDTH: INTEGER:=16 );
		PORT(   Dout: 	IN 		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				en:		IN 		STD_LOGIC;
				Din:	OUT		STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
				IOpin: 	INOUT 	STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL CHIP_SELECTOR			 		: STD_LOGIC_VECTOR( 6 DOWNTO 0 );
	SIGNAL HEX_0_EN :STD_LOGIC;
	SIGNAL HEX_1_EN :STD_LOGIC;
	SIGNAL HEX_2_EN :STD_LOGIC;
	SIGNAL HEX_3_EN :STD_LOGIC;
	SIGNAL HEX_4_EN :STD_LOGIC;
	SIGNAL HEX_5_EN :STD_LOGIC;
	SIGNAL LED_EN :STD_LOGIC;
	SIGNAL SWITCH_DATA, Data_From_Bus			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL PORT_LEDR_TEMP		: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PORT_HEX0_TEMP		: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PORT_HEX1_TEMP		: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PORT_HEX2_TEMP		: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PORT_HEX3_TEMP		: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PORT_HEX4_TEMP		: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PORT_HEX5_TEMP		: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL SW_EN                :   STD_LOGIC;
	--SIGNAL clk_not :STD_LOGIC;

BEGIN
	BiDirPin_GPIO: BidirPin
	GENERIC MAP ( 32 )
	PORT MAP (	Dout 		=> SWITCH_DATA, --change names later
    	    	en			=> SW_EN,--only switches can enable writing to bus
				Din			=> Data_From_Bus,
				IOpin 		=> DB );

	--clk_not <= NOT clock;

	WITH address(4 downto 1) SELECT --address is adress bus bits 11,4,3,2
		CHIP_SELECTOR <= "0000001" WHEN "1000",--800 (LEDS)
			  "0000010" WHEN "1001",--804,805 (HEX 0 and 1)
			  --"0000100" WHEN "1001",--805
			  "0000100" WHEN "1010",--808,809 (HEX 2 and 3)
			  --"0010000" WHEN "1100",--809
			  "0001000" WHEN "1011",--80C,80D (HEX 4 and 5)
			  --"1000000" WHEN "1110",--80D
			  "0010000" WHEN "1100",--810 (switches)
			  "0000000" WHEN OTHERS;		

	
	
	LED_EN <= MemWrite AND CHIP_SELECTOR(0);--enabale writing to leds IO
	--adress zero = 0 is even IO else odd IO
	HEX_0_EN <= MemWrite AND CHIP_SELECTOR(1) AND (not address(0));
	HEX_1_EN <= MemWrite AND CHIP_SELECTOR(1) AND address(0);
	HEX_2_EN <= MemWrite AND CHIP_SELECTOR(2) AND (not address(0));
	HEX_3_EN <= MemWrite AND CHIP_SELECTOR(2) AND address(0);
	HEX_4_EN <= MemWrite AND CHIP_SELECTOR(3) AND (not address(0));
	HEX_5_EN <= MemWrite AND CHIP_SELECTOR(3) AND address(0);
	
	
	PROCESS(reset, clock)
	BEGIN
		IF reset = '1' THEN
			PORT_LEDR_TEMP <= X"00";
		ELSIF ( clock'EVENT ) AND ( clock = '1' ) THEN
			IF (LED_EN = '1' and IO_ADRESS_DIFFER ='0') THEN
				PORT_LEDR_TEMP <= Data_From_Bus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(reset, clock)
	BEGIN
		IF reset = '1' THEN
			PORT_HEX0_TEMP <= X"00";
		ELSIF ( clock'EVENT ) AND ( clock = '1' ) THEN
			IF (HEX_0_EN = '1' and IO_ADRESS_DIFFER ='0') THEN
				PORT_HEX0_TEMP <= Data_From_Bus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(reset, clock)
	BEGIN
		IF reset = '1' THEN
			PORT_HEX1_TEMP <= X"00";
		ELSIF ( clock'EVENT ) AND ( clock = '1' ) THEN
			IF (HEX_1_EN = '1' and IO_ADRESS_DIFFER ='0') THEN
				PORT_HEX1_TEMP <= Data_From_Bus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(reset, clock)
	BEGIN
		IF reset = '1' THEN
			PORT_HEX2_TEMP <= X"00";
		ELSIF ( clock'EVENT ) AND ( clock = '1' ) THEN
			IF (HEX_2_EN = '1' and IO_ADRESS_DIFFER ='0') THEN
				PORT_HEX2_TEMP <= Data_From_Bus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(reset, clock)
	BEGIN
		IF reset = '1' THEN
			PORT_HEX3_TEMP <= X"00";
		ELSIF ( clock'EVENT ) AND ( clock = '1' ) THEN
			IF (HEX_3_EN = '1' and IO_ADRESS_DIFFER ='0') THEN
				PORT_HEX3_TEMP <= Data_From_Bus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(reset, clock)
	BEGIN
		IF reset = '1' THEN
			PORT_HEX4_TEMP <= X"00";
		ELSIF ( clock'EVENT ) AND ( clock = '1' ) THEN
			IF (HEX_4_EN = '1' and IO_ADRESS_DIFFER ='0') THEN
				PORT_HEX4_TEMP <= Data_From_Bus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(reset, clock)
	BEGIN
		IF reset = '1' THEN
			PORT_HEX5_TEMP <= X"00";
		ELSIF ( clock'EVENT ) AND ( clock = '1' ) THEN
			IF (HEX_5_EN = '1' and IO_ADRESS_DIFFER ='0') THEN
				PORT_HEX5_TEMP <= Data_From_Bus(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	--output from hex and ldr latches
	PORT_LEDR <= PORT_LEDR_TEMP;
	PORT_HEX0 <= PORT_HEX0_TEMP;
	PORT_HEX1 <= PORT_HEX1_TEMP;
	PORT_HEX2 <= PORT_HEX2_TEMP;
	PORT_HEX3 <= PORT_HEX3_TEMP;
	PORT_HEX4 <= PORT_HEX4_TEMP;
	PORT_HEX5 <= PORT_HEX5_TEMP;
	
	--switch write
	SW_EN <= '1' WHEN MemRead = '1' AND CHIP_SELECTOR(4) = '1' ELSE '0';
	SWITCH_DATA <= X"000000" & PORT_SW;

end gpio_arc;