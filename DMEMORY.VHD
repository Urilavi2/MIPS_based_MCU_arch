						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	GENERIC (
	modelsim : integer := 0 );
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ADRESS_BUS			: in	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			ACK					: in	STD_LOGIC;
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock,mem_write_en : STD_LOGIC;
SIGNAL address_for_quartus : STD_LOGIC_VECTOR( 10 DOWNTO 0 );
signal address2 : STD_LOGIC_VECTOR( 8 DOWNTO 0 );
BEGIN

	
	simulation:if (modelsim = 1) generate
		data_memory : altsyncram
		GENERIC MAP  (
			operation_mode => "SINGLE_PORT",
			width_a => 32,
			widthad_a => 9,--adress space of 0x800/4 (every address in simulation is 4 bytes)
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\vhdl_files\fpga_labs\final_project\data1.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			-- wren_a => memwrite,
			wren_a => mem_write_en,
			clock0 => write_clock,
			address_a => address2,
			data_a => write_data,
			q_a => read_data	);
			write_clock <= NOT clock;
	end generate;
	
	
	quartus:if (modelsim = 0) generate
		data_memory : altsyncram
		GENERIC MAP  (
			operation_mode => "SINGLE_PORT",
			width_a => 32,
			widthad_a => 11,--adress space of 0x800 (every address in simulation is 1 byte)
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "C:\vhdl_files\fpga_labs\final_project\data1.hex",
			intended_device_family => "Cyclone"
		)
		PORT MAP (
			-- wren_a => memwrite,
			wren_a => mem_write_en,
			clock0 => write_clock,
			address_a => address_for_quartus,
			data_a => write_data,
			q_a => read_data	);
			write_clock <= NOT clock;
	end generate;
	
	--enables memory only when memwrite control is on and adress is less than 0x800
	mem_write_en <= '1' when address(31 downto 11) = x"0000" & B"0" and Memwrite = '1' else '0';
	--when ack is 0 the requaired adress is coming from the interrupt controller via the bus
	address2 <= address(10 downto 2) when ack = '1' else "000" & ADRESS_BUS(7 downto 2);
	--quartus adress is by byte unlike simulation
	address_for_quartus <= address2 & "00";
	
	
END behavior;

