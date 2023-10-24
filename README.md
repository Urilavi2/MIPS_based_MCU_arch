--------------- Final Project - MIPS based MCU Architecture --------------- 

		Uri Lavi --- 205945793
		Yair Ross -- 207287889

This file will brief functional description of every file of our system.
---------------------------------------------------------------------------

LIST OF FILES:
--------------
1)  BASIC_TIMER.vhd
2)  BidirPin.vhd
3)  CONTROL.vhd
4)  DMEMORY.vhd
5)  EXECUTE.vhd
6)  GPIO.vhd
7)  IDECODE.vhd
8)  IFETCH.vhd
9)  INTERRUPT_CONTROL.vhd
10) MCU_TOP.vhd
11) MIPS.vhd
12) seven_seg_conv.vhd
13) Shifter.vhd

-------------------------------------------------------------

DESCRIPTION:
------------
1)  BASIC_TIMER.vhd: Basic timer with inerrupt option by 7 time intevals. Can also make a PWM wave on output

2)  BidirPin: 	 used for creating our Bi-directional BUS.

3)  CONTROL.vhd: gets the instruction opcode and outputs the apropriate signals.

4)  DMEMORY.vhd: responsible to read and write to memory.

5)  EXECUTE.vhd: contains the alu and makes all the arithmetic oparation.

6)  GPIO.vhd: 	 Manage the GPIO components.

7)  IDECODE.vhd: Decodes the instruction and also makes the branch decision (to provide less stalls) also contains the Write Back
		 part of the mips wich responsible to write to register file.

8)  IFETCH.vhd:	 Fetch component of the code responsible to fetch next pc address.

9)  INTERRUPT_CONTROL.vhd: Communicate with the MIPS core and notify when an interrupt has occured. Put the ISR address on the DATA bus when recived INTA.

10) MCU_TOP.vhd: The top level of the code. Connects between the MIPS core, the Interrupt controller and the I\O devices.

11) MIPS.vhd: MIPS core. Connects IFETCH, IDECODE, EXECUTE and DMEMORY to one entity.

12) seven_seg_conv.vhd: This file recieve 4 bits repesenting a binary number and convert it to 7 segment number.

13) Shifter.vhd: The component gets 2 n-size binary vectors and a 3 bit control vector.
		 this component will shift right or left the second input vector by the [2:0] bits of the first input.
		 the decision which shift will take action is decided by the control vector.



