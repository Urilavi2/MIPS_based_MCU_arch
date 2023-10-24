-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	GENERIC (
		modelsim : integer := 0 );
	PORT(	SIGNAL PC_EN			: IN STD_LOGIC;
			SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Branch 			: IN 	STD_LOGIC_VECTOR( 1 downto 0);
        	SIGNAL Zero 			: IN 	STD_LOGIC;
			signal Jump 			: IN 	STD_LOGIC;
			signal jumpi            : in    STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			signal JumpReg          : in    STD_LOGIC;
			signal read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			SIGNAL ISR_JUMP			: IN    STD_LOGIC;
			SIGNAL ISR_ADDRESS		: IN    STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			SIGNAL DONT_CHANGE_PC	: IN 	STD_LOGIC;
        	SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC, Next_PC_1, Next_PC_2, Mem_Addr : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL address_for_quartus : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
BEGIN
						--ROM for Instruction Memory

	address_for_quartus <= Mem_Addr & "00";
	
	simulation:if (modelsim = 1) generate
		inst_memory: altsyncram
		GENERIC MAP (
			operation_mode => "ROM",
			width_a => 32,
			widthad_a => 8,
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\vhdl_files\fpga_labs\final_project\program1.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			clock0     => clock,
			address_a 	=> Mem_Addr, 
			q_a 			=> Instruction );
	end generate;
	
	
	quartus:if (modelsim = 0) generate
		inst_memory: altsyncram
		GENERIC MAP (
			operation_mode => "ROM",
			width_a => 32,
			widthad_a => 10,
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\vhdl_files\fpga_labs\final_project\program1.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			clock0     => clock,
			address_a 	=> address_for_quartus, 
			q_a 			=> Instruction );
	end generate;
		
		
	
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		Mem_Addr <= Next_PC;
						-- Adder to increment PC by 4        
      	-- PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) when (DONT_CHANGE_PC = '1' and (Branch(0) = '1' 
									-- or Branch(1) = '1' or Jump = '1' or JumpReg = '1')) else PC( 9 DOWNTO 2 ) + 1;
		PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) when (DONT_CHANGE_PC = '1') else PC( 9 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4  
		Next_PC_1 <= X"00" WHEN Reset = '1' ELSE
			Add_result  WHEN (( ( Branch(0) = '1' ) AND ( Zero = '1' ) ) or ( ( Branch(1) = '1' ) AND ( Zero = '0' ) )) 
			ELSE   PC_plus_4( 9 DOWNTO 2 );
		Next_PC_2 <= Next_PC_1 WHEN Jump='0' ELSE
					Jumpi WHEN Jump='1';
		Next_PC		<= 	ISR_ADDRESS WHEN ISR_JUMP = '1' else
						Next_PC_2 WHEN JumpReg='0' ELSE
					   read_data_1(9 downto 2) WHEN JumpReg='1';
		-- Next_PC  <= X"00" WHEN Reset = '1' ELSE
			-- Add_result  WHEN (( ( Branch(0) = '1' ) AND ( Zero = '1' ) ) or ( ( Branch(1) = '1' ) AND ( Zero = '0' ) )) 
			-- ELSE   PC_plus_4( 9 DOWNTO 2 );
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC( 9 DOWNTO 2) <= "00000000" ; 
			ELSIF PC_EN = '1' THEN
				   PC( 9 DOWNTO 2 ) <= next_PC;
			END IF;
	END PROCESS;
END behavior;


