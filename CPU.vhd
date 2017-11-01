library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port(
		RESET			: in  std_logic;
		CLK 			: in  std_logic;
		OUTPUT		: out std_logic
	);
end entity CPU;

architecture ATMEGA_CPU of CPU is
	constant PROGMEM_SIZE 	: integer := 12; --4 k (words)
	constant DATAMEM_SIZE 	: integer := 16; --64 kb
	constant STACKMEM_SIZE	: integer := 10; --1 k (words)
	
	constant ZEROS	: std_logic_vector(15 downto 0) := (others => '0');
	
	signal stack_p	: std_logic_vector(STACKMEM_SIZE-1 downto 0);
	
	signal p_wr		: std_logic := '0';
	signal p_addr	: std_logic_vector(PROGMEM_SIZE-1 downto 0);
	signal p_dw		: std_logic_vector(15 downto 0) := (others => '0');
	signal p_dr		: std_logic_vector(15 downto 0);
	
	signal d_wr		: std_logic;
	signal d_addr	: std_logic_vector(DATAMEM_SIZE-1 downto 0);
	signal d_dw		: std_logic_vector(7 downto 0);
	signal d_dr		: std_logic_vector(7 downto 0);
	
	signal s_wr		: std_logic;
	signal s_addr	: std_logic_vector(STACKMEM_SIZE-1 downto 0);
	signal s_dw		: std_logic_vector(15 downto 0);
	signal s_dr		: std_logic_vector(15 downto 0);
		
	type register_t is array (0 to 31) of std_logic_vector(7 downto 0);
	signal reg			: register_t;
	signal Rd			: std_logic_vector(4 downto 0);
	signal Rr			: std_logic_vector(4 downto 0);
	signal offset		: std_logic_vector(7 downto 0);
	signal imm			: std_logic_vector(15 downto 0);
	signal pre_dec		: std_logic;
	signal post_dec	: std_logic;
	signal status		: std_logic_vector(7 downto 0);
	signal bits			: std_logic_vector(2 downto 0);
	
	signal opcode		: integer range 0 to 255;
	
	signal aluX			: signed(15 downto 0);
	signal aluY			: signed(7 downto 0);
	signal aluControl : std_logic_vector(4 downto 0);
	signal aluS_in		: std_logic_vector(7 downto 0);
	signal aluS_out	: std_logic_vector(7 downto 0);
	signal aluResult	: signed(15 downto 0);
	
	type cpu_states is (EXECUTE1, EXECUTE2, EXECUTE3, HALT);
	signal state: cpu_states := EXECUTE1;
	
	alias pc 				: std_logic_vector(PROGMEM_SIZE-1 downto 0) 	is p_addr;
	alias instruction 	: std_logic_vector(15 downto 0) 					is p_dr;
	
	shared variable pc_inc  : integer range -32768 to 32767;
	
	shared variable VRd		: std_logic_vector(4 downto 0);
	shared variable VRr		: std_logic_vector(4 downto 0);
	shared variable d5		: std_logic_vector(4 downto 0);
	shared variable d4		: std_logic_vector(3 downto 0);
	shared variable d3		: std_logic_vector(2 downto 0);
	shared variable r5		: std_logic_vector(4 downto 0);
	shared variable r4		: std_logic_vector(3 downto 0);
	shared variable r3		: std_logic_vector(2 downto 0);
	shared variable imm12   : std_logic_vector(11 downto 0);
	shared variable imm8		: std_logic_vector(7 downto 0);
	shared variable imm7		: std_logic_vector(6 downto 0);
	shared variable imm6		: std_logic_vector(5 downto 0);

	shared variable i2		: std_logic_vector(1 downto 0);
	shared variable i4		: std_logic_vector(3 downto 0);
	shared variable bnum    : std_logic_vector(2 downto 0);
	
	shared variable immV		: integer range -32768 to 32767;
	shared variable pcV		: integer range 0 to 65535;

begin

	-- Program memory: 4 K (words), 16-bit wide, read-only
	make_progMem: entity work.mem16
	generic map(
		AddrWidth => PROGMEM_SIZE
	)
	port map(
		clock => CLK,
		addr => p_addr,
		dr => p_dr,
		dw => p_dw,
		wr => p_wr
	);
	
	-- Data memory: 64 KB, 8-bit wide, read/write
	make_dataMem: entity work.mem8
	generic map(
		AddrWidth => DATAMEM_SIZE
	)
	port map(
		clock => CLK,
		wr => d_wr,
		addr => d_addr,
		dw => d_dw,
		dr => d_dr
	);
	-- *************is being loaded with prog_init
	-- Stack memory: 1 K (words), 16-bit wide, read/write  ************* FIX!!! is being loaded with prog_init
	make_stackMem: entity work.mem16
	generic map(
		AddrWidth => STACKMEM_SIZE
	)
	port map(
		clock => CLK,
		wr => s_wr,
		addr => s_addr,
		dw => s_dw,
		dr => s_dr
	);
	
	alu_entity: entity work.alu
	port map(
		X => aluX,
		Y => aluY,
		CONTROL => aluControl,
		STATUS_IN => aluS_in,
		STATUS_OUT => aluS_out,
		OUTPUT => aluResult
	);
	
	cpu_state_machine: process(CLK, RESET)
	begin
		if RESET = '1' then
			pc <= (others => '0'); -- reset program counter
			status <= (others => '0');
			reg <= ((others=> (others=>'0')));
			stack_p <= (others => '0');
			s_addr <= (others => '0');
			s_dw <= (others => '0');
			
			-- reset everything, data memory, stack, other registers, etc.
		elsif rising_edge(CLK) then
			OUTPUT <= reg(0)(0);
		
			d5		:= instruction(8 downto 4);
			d4		:= instruction(7 downto 4);
			d3		:= instruction(6 downto 4);
			r5		:= instruction(9) & instruction(3 downto 0);
			r4		:= instruction(3 downto 0);
			r3		:= instruction(2 downto 0);
			imm12 := instruction(11 downto 0);
			imm8	:= instruction(11 downto 8) & instruction(3 downto 0);
			imm7	:= instruction(9 downto 3);
			bnum	:= instruction(2 downto 0);
			pc_inc 	:= 1;
			s_wr <= '0';
			d_wr <= '0';
			
			case state is
				when EXECUTE1 => 
					case instruction(15) is
						when '0' =>
							case instruction(14 downto 12) is
								when "000" =>
									case instruction(11 downto 10) is
										when "00" =>
											case instruction(9 downto 8) is
												when "00" => 										--01. NOP  : No Operation 
													NULL;
													
												when "01" => 										--02. MOVW : Copy Register Pair
													VRd := d4 & '0';
													VRr := r4 & '1';
													reg(to_integer(unsigned(VRd))) <= reg(to_integer(unsigned(VRr)));
													reg(to_integer(unsigned(VRd))+1) <= reg(to_integer(unsigned(VRr))+1);
													
												when "10" => 										--03. MULS : Multiply Signed
													opcode <= 3;
													aluX <= "00000000" & signed(reg(to_integer(unsigned('1' & d4))));
													aluY <= signed(reg(to_integer(unsigned('1' & r4))));
													aluControl <= std_logic_vector(to_unsigned(25, 5));	-- MULS
													aluS_in <= status;
											
													Rd <= "00000"; 		--0 for MUL
													
													pc_inc := 0;
													state <= EXECUTE2;

												when "11" =>
													i2 := instruction(7) & instruction(3);
													case i2 is
														when "00" => 								--04. MULSU  : Multiply Signed with Unsigned
															opcode <= 3;
															aluX <= "00000000" & signed(reg(to_integer("10" & unsigned(d3))));
															aluY <= signed(reg(to_integer("10" & unsigned(r3))));
															aluControl <= std_logic_vector(to_unsigned(26, 5));	-- MULSU
															aluS_in <= status;
													
															Rd <= "00000"; 		--0 for MUL
															
															pc_inc := 0;
															state <= EXECUTE2;
														when "10" => 								--05. FMULS  : Fractional Multiply Signed
															opcode <= 3;
															aluX <= "00000000" & signed(reg(to_integer("10" & unsigned(d3))));
															aluY <= signed(reg(to_integer("10" & unsigned(r3))));
															aluControl <= std_logic_vector(to_unsigned(28, 5));	-- FMULS
															aluS_in <= status;
													
															Rd <= "00000"; 		--0 for MUL
															
															pc_inc := 0;
															state <= EXECUTE2;
														when "01" => 								--06. FMUL   : Fractional Multiply Unsigned
															opcode <= 3;
															aluX <= "00000000" & signed(reg(to_integer("10" & unsigned(d3))));
															aluY <= signed(reg(to_integer("10" & unsigned(r3))));
															aluControl <= std_logic_vector(to_unsigned(27, 5));	-- FMULU
															aluS_in <= status;
													
															Rd <= "00000"; 		--0 for MUL
															
															pc_inc := 0;
															state <= EXECUTE2;
														when "11" => 								--07. FMULSU : Fractional Multiply Signed with Unsigned
															opcode <= 3;
															aluX <= "00000000" & signed(reg(to_integer("10" & unsigned(d3))));
															aluY <= signed(reg(to_integer("10" & unsigned(r3))));
															aluControl <= std_logic_vector(to_unsigned(29, 5));	-- FMULSU
															aluS_in <= status;
													
															Rd <= "00000"; 		--0 for MUL
															
															pc_inc := 0;
															state <= EXECUTE2;
														when others => -- NOP
															NULL;
													end case;
												when others => -- NOP
													NULL;
											end case;
										when "01" => 												--08. CPC  : Compare with Carry
											opcode <= 8;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(4, 5));	-- SBC
											aluS_in <= status;
											
											pc_inc := 0;
											state <= EXECUTE2;

										when "10" => 												--09. SBC  : Subtract with Carry
											opcode <= 9;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(4, 5));	-- SBC
											aluS_in <= status;
											
											Rd <= d5;
											
											pc_inc := 0;
											state <= EXECUTE2;
										
										when "11" => 												--10. ADD  : Add without Carry
											opcode <= 9;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(0, 5));	--ADD
											aluS_in <= status;
											
											Rd <= d5;
											
											pc_inc := 0;
											state <= EXECUTE2;
										
										when others => -- NOP
											NULL;
									end case;
								when "001" =>
									case instruction(11 downto 10) is
										when "00" => 												--11. CPSE : Compare, skip if Equal
											opcode <= 11;
											state <= EXECUTE2;
											
										when "01" => 												--12. CP   : Compare
											opcode <= 8;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(3, 5));	--SUB
											aluS_in <= status;
											
											pc_inc := 0;
											state <= EXECUTE2;
										when "10" => 												--13. SUB  : Subtract without Carry
											opcode <= 9;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(3, 5));	--SUB
											aluS_in <= status;
											
											Rd <= d5;
											
											pc_inc := 0;
											state <= EXECUTE2;
										when "11" => 												--14. ADC  : Add with Carry
											opcode <= 9;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(1, 5));	--ADC
											aluS_in <= status;
											
											Rd <= d5;
											
											pc_inc := 0;
											state <= EXECUTE2;
										when others => -- NOP
											NULL;
									end case;
								when "010" =>
									case instruction(11 downto 10) is
										when "00" => 												--15. AND  : Logical AND 
											opcode <= 9;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(7, 5));	--AND
											aluS_in <= status;
											
											Rd <= d5;
											
											pc_inc := 0;
											state <= EXECUTE2;
										when "01" => 												--16. EOR  : Exclusive OR
											opcode <= 9;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(9, 5));	--XOR
											aluS_in <= status;
											
											Rd <= d5;
											
											pc_inc := 0;
											state <= EXECUTE2;
										when "10" => 												--17. OR   : Logical OR
											opcode <= 9;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(8, 5));	--OR
											aluS_in <= status;
											
											Rd <= d5;
											
											pc_inc := 0;
											state <= EXECUTE2;
										when "11" => 												--18. MOV  : Copy Register
											reg(to_integer(unsigned(d5))) <= reg(to_integer(unsigned(r5)));
											
										when others => -- NOP
											NULL;
									end case;
								when "011" => 														--19. CPI  : Compare with Immediate
									opcode <= 8;
									aluX <= "00000000" & signed(reg(to_integer(unsigned('1' & d4))));
									aluY <= signed(imm8);
									aluControl <= std_logic_vector(to_unsigned(3, 5));	--SUB
									aluS_in <= status;
									
									pc_inc := 0;
									state <= EXECUTE2;
								
								when "100" => 														--20. SBCI : Subtract Immediate with Carry
									opcode <= 9;
									aluX <= "00000000" & signed(reg(to_integer(unsigned('1' & d4))));
									aluY <= signed(imm8);
									aluControl <= std_logic_vector(to_unsigned(4, 5));	--SBC
									aluS_in <= status;
									
									Rd <= '1' & d4;
									
									pc_inc := 0;
									state <= EXECUTE2;
								
								when "101" => 														--21. SUBI : Subtract Immediate
									opcode <= 9;
									aluX <= "00000000" & signed(reg(to_integer(unsigned('1' & d4))));
									aluY <= signed(imm8);
									aluControl <= std_logic_vector(to_unsigned(3, 5));	--SUB
									aluS_in <= status;
									
									Rd <= '1' & d4;
									
									pc_inc := 0;
									state <= EXECUTE2;
								
								when "110" => 														--22. ORI  : Logical OR with Immediate
									opcode <= 9;
									aluX <= "00000000" & signed(reg(to_integer(unsigned('1' & d4))));
									aluY <= signed(imm8);
									aluControl <= std_logic_vector(to_unsigned(8, 5));	--OR
									aluS_in <= status;
									
									Rd <= '1' & d4;
									
									pc_inc := 0;
									state <= EXECUTE2;
								
								when "111" => 														--23. ANDI : Logical AND with Immediate
									opcode <= 9;
									aluX <= "00000000" & signed(reg(to_integer(unsigned('1' & d4))));
									aluY <= signed(imm8);
									aluControl <= std_logic_vector(to_unsigned(7, 5));	--AND
									aluS_in <= status;
									
									Rd <= '1' & d4;
									
									pc_inc := 0;
									state <= EXECUTE2;

								when others => -- NOP
									NULL;
							end case;
						when '1' =>
							case instruction(14 downto 12) is
								when "000" => 
									i2 := instruction(9) & instruction(3);
									case i2 is
										when "10" => 												--24. ST  : Store Indirect Z
											
										when "11" => 												--25. ST  : Store Indirect Y
											
										when "00" => 												--26. LD  : Load Indirect Y
											
										when "01" => 												--27. LD  : Load Indirect Z
											
										when others => -- NOP
											NULL;
									end case;
								when "001" =>
									case instruction(11) is
										when '0' =>
											i4 := instruction(3 downto 0);
											case instruction(10 downto 9) is
												when "00" => 
													case i4 is
														when "0000" => 								--28. LDS : Load Direct from data space 16-bit
															opcode <= 28;
															Rd <= d5;
															state <= EXECUTE2;
														when "1100" => 								--29. LD  : Load Indirect X
															
														when "0010" => 								--30. LD  : Load Indirect Z and Pre Decrement
															
														when "1010" => 								--31. LD  : Load Indirect Y and Pre Decrement
															
														when "1110" => 								--32. LD  : Load Indirect X and Pre Decrement
															
														when "0001" => 								--33. LD  : Load Indirect Z and Post Increment
															
														when "1001" => 								--34. LD  : Load Indirect Y and Post Increment
															
														when "1101" => 								--35. LD  : Load Indirect X and Post Increment
															
														when "1111" => 								--36. POP : Pop Register from Stack
															s_addr <= stack_p;
															Rd <= d5;
															opcode <= 36;
															pc_inc := 0;
															state <= EXECUTE2;
															
														when others => -- NOP
															NULL;
													end case;
												when "01" => 
													case i4 is
														when "0000" => 								--37. STS  : Store Direct to Data Space 16-bit
															Rd <= d5;
															opcode <= 37;
															state <= EXECUTE2;
														when "1111" => 								--38. PUSH : Push Register on Stack
															s_wr <= '1';
															s_addr <= stack_p;
															s_dw <= ZEROS(15 downto 5) & d5;
															stack_p <= std_logic_vector( unsigned(stack_p) + 1 );
															
														when "0100" => 								--39. XCH  : Exchange Z
															
														when "1100" => 								--40. ST   : Store Indirect X
															
														when "0010" => 								--41. ST   : Store Indirect Z and Pre Decrement
															
														when "1010" => 								--42. ST   : Store Indirect Y and Pre Decrement
															
														when "0110" => 								--43. LAC  : Load and Clear Z
															
														when "1110" => 								--44. ST   : Store Indirect X and Pre Decrement
															
														when "0001" => 								--45. ST   : Store Indirect Z and Post Decrement
															
														when "1001" => 								--46. ST   : Store Indirect Y and Post Decrement
															
														when "0101" => 								--47. LAS  : Load and Set Z
															
														when "1101" => 								--48. ST   : Store Indirect X and Post Decrement
															
														when "0111" => 								--49. LAT  : Load and Toggle Z
															
														when others => -- NOP
															NULL;
													end case;
												when "10" => 
													case i4 is
														when "0000" => 								--50. COM  : One’s Complement
															opcode <= 9;
															aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
															aluY <= "--------";
															aluControl <= std_logic_vector(to_unsigned(10, 5));	--NOT
															aluS_in <= status;
															
															Rd <= d5;
															
															pc_inc := 0;
															state <= EXECUTE2;
														
														when "0001" => 								--51. NEG  : Two’s Complement
															opcode <= 9;
															aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
															aluY <= "--------";
															aluControl <= std_logic_vector(to_unsigned(6, 5));	--NEG
															aluS_in <= status;
															
															Rd <= d5;
															
															pc_inc := 0;
															state <= EXECUTE2;

														when "0010" => 								--52. SWAP : Swap Nibbles 
															
														when "0011" => 								--53. INC  : Increment
															opcode <= 9;
															aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
															aluY <= "--------";
															aluControl <= std_logic_vector(to_unsigned(2, 5));	--INC
															aluS_in <= status;
															
															Rd <= d5;
															
															pc_inc := 0;
															state <= EXECUTE2;

														when "0101" => 								--54. ASR  : Arithmetic Shift Right
															opcode <= 9;
															aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
															aluY <= "--------";
															aluControl <= std_logic_vector(to_unsigned(13, 5));	--ASR
															aluS_in <= status;
															
															Rd <= d5;
															
															pc_inc := 0;
															state <= EXECUTE2;

														when "0110" => 								--55. LSR  : Logical Shift Right
															opcode <= 9;
															aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
															aluY <= "--------";
															aluControl <= std_logic_vector(to_unsigned(12, 5));	--LSR
															aluS_in <= status;
															
															Rd <= d5;
															
															pc_inc := 0;
															state <= EXECUTE2;

														when "0111" => 								--56. ROR  : Rotate Right Through Carry
															opcode <= 9;
															aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
															aluY <= "--------";
															aluControl <= std_logic_vector(to_unsigned(15, 5));	--ROR
															aluS_in <= status;
															
															Rd <= d5;
															
															pc_inc := 0;
															state <= EXECUTE2;

														when "1000" =>
															case instruction(8 downto 7) is
																when "00" => 						--57. BSET : Flag Set
																	bnum := instruction(6 downto 4);
																	status(to_integer(unsigned(bnum))) <= '1'; 
																	
																when "01" => 						--58. BCLR : Flag Clear
																	bnum := instruction(6 downto 4);
																	status(to_integer(unsigned(bnum))) <= '0'; 
																	
																when "10" => 						--59. RET  : Subroutine Return
																	s_addr <= stack_p;
																	opcode <= 59;
																	pc_inc := 0;
																	state <= EXECUTE2;
																	
																when others => -- NOP
																	NULL;
															end case;
														when "1001" =>
															case instruction(8) is
																when '0' => 						--60. IJMP  : Indirect Jump to (Z)
																	pc(PROGMEM_SIZE-1 downto 8) <= reg(30)(PROGMEM_SIZE-9 downto 0);
																	pc( 7 downto 0) <= reg(31);
																	
																when '1' => 						--61. ICALL : Indirect Call to (Z)
																	s_addr <= stack_p;
																	s_wr <= '1';
																	s_dw <=  ZEROS(15 downto PROGMEM_SIZE) & std_logic_vector( unsigned(pc) + 1 );
																	stack_p <= std_logic_vector( unsigned(stack_p) + 1 );
																	pc <= reg(30)(PROGMEM_SIZE-9 downto 0) & reg(31);
																	
																when others => -- NOP
																	NULL;
															end case;
														when "1010" => 								--62. DEC  : Decrement
															opcode <= 9;
															aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
															aluY <= "--------";
															aluControl <= std_logic_vector(to_unsigned(5, 5));	--INC
															aluS_in <= status;
															
															Rd <= d5;
															
															pc_inc := 0;
															state <= EXECUTE2;
															
														when others => -- NOP
															NULL;
													end case;
													case instruction(3 downto 1) is
														when "110" => 								--63. JMP  : Jump
															opcode <= 63;
															pc_inc := 0;
															-- we have only 64k (16bit) of addressable memory, so the 6 bits of address here are ignored.
															state <= EXECUTE2;
															
														when "111" => 								--64. CALL : Call Subroutine
															s_wr <= '1';
															s_addr <= stack_p;
															s_dw <= ZEROS(15 downto PROGMEM_SIZE) & std_logic_vector( unsigned(pc) + 2);
															stack_p <= std_logic_vector( unsigned(stack_p) + 1 );
															opcode <= 64;
															pc_inc := 0;
															state <= EXECUTE2;
															
														when others => -- NOP
															NULL;
													end case;
												when "11" =>
													imm6 := instruction(7 downto 6) & instruction(3 downto 0);
													VRd := "11" & instruction(5 downto 4) & "0";
													case instruction(8) is
														when '0' => 								--65. ADIW : Add Immediate to Word
															opcode <= 3;
															aluX <= signed(reg(to_integer(unsigned(VRd))+1)) & signed(reg(to_integer(unsigned(VRd))));
															aluY <= resize(signed(imm6), 8);
															aluControl <= std_logic_vector(to_unsigned(16, 5));	--ADIW
															aluS_in <= status;
															
															Rd <= Vrd;
															
															pc_inc := 0;
															state <= EXECUTE2;

														when '1' => 								--66. SBIW : Subtract Immediate from Word
															opcode <= 3;
															aluX <= signed(reg(to_integer(unsigned(VRd))+1)) & signed(reg(to_integer(unsigned(VRd))));
															aluY <= resize(signed(imm6), 8);
															aluControl <= std_logic_vector(to_unsigned(17, 5));	--SBIW
															aluS_in <= status;
															
															Rd <= Vrd;
															
															pc_inc := 0;
															state <= EXECUTE2;
														when others => -- NOP
															NULL;
													end case;
												when others => -- NOP
													NULL;
											end case;
										when '1' => 												--67. MUL  : Multiply Unsigned
											opcode <= 3;
											aluX <= "00000000" & signed(reg(to_integer(unsigned(d5))));
											aluY <= signed(reg(to_integer(unsigned(r5))));
											aluControl <= std_logic_vector(to_unsigned(24, 5));	-- MULU
											aluS_in <= status;
									
											Rd <= "00000"; 		--0 for MUL
											
											pc_inc := 0;
											state <= EXECUTE2;
										when others => -- NOP
											NULL;
									end case;
								when "010" =>
									case instruction(11) is
										when '0' => 												--68. LDS : Load Direct from data space 7-bit
											NULL;
										when '1' => 												--69. STS : Store Direct to Data Space 7-bit
											NULL;
										when others => -- NOP
											NULL;
									end case;
								when "100" => 														--74. RJMP  : Relative Jump 
									--pc <= std_logic_vector( unsigned(to_integer(unsigned(pc)) + to_integer(signed(imm12))) ); 
									--pc <= std_logic_vector( unsigned(pc)+signed(imm12) );
									immV := to_integer(unsigned(imm12));
									pcV  := to_integer(unsigned(pc)) + immV;
									pc   <= std_logic_vector(to_unsigned(pcV, PROGMEM_SIZE));
									
								when "101" => 														--75. RCALL : Relative Call Subroutine
									s_addr <= stack_p;
									s_dw <= ZEROS(15 downto PROGMEM_SIZE) & std_logic_vector( unsigned(pc) + 1);
									stack_p <= std_logic_vector( unsigned(stack_p) + 1 );
									--pc <= std_logic_vector( unsigned(pc) + signed(imm12) );
									immV := to_integer(unsigned(imm12));
									pcV  := to_integer(unsigned(pc)) + immV;
									pc   <= std_logic_vector(to_unsigned(pcV, PROGMEM_SIZE));
									
								when "110" => 														--76. LDI   : Load Immediate
									VRd := '1' & d4;
									reg(to_integer(unsigned(VRd))) <= imm8;
									
								when "111" =>
									case instruction(11 downto 10) is
										when "00" => 												--77. BRBS : Branch if Status Flag Set
											opcode <= 80;
											if status(to_integer(unsigned(bnum))) = '1' then
												pc_inc := to_integer(signed(imm7)) + 1;
												state <= EXECUTE2;
											end if;
											
										when "01" => 												--78. BRBC : Branch if Status Flag Cleared
											opcode <= 80;
											if status(to_integer(unsigned(bnum))) = '0' then
												pc_inc := to_integer(signed(imm7)) + 1;
												state <= EXECUTE2;
											end if;
											
										when "11" =>
											case instruction(9) is
												when '0' => 										--79. SBRC : Skip if Bit in Register Cleared
													opcode <= 80;
													if reg(to_integer(unsigned(d5)))(to_integer(unsigned(bnum))) = '0' then
														state <= EXECUTE2;
													end if;
													
												when '1' => 										--80. SBRS : Skip if Bit in Register Set
													opcode <= 80;
													Rr <= d5;
													bits <= bnum;
													--pc_inc := 0;
													if reg(to_integer(unsigned(d5)))(to_integer(unsigned(bnum))) = '1' then
														state <= EXECUTE2;
													end if;
													
												when others => -- NOP
													NULL;
											end case;
										when others => -- NOP
											NULL;
									end case;
								when others => -- NOP
									NULL;
							end case;
						when others => -- NOP
							NULL;
					end case;

				------------------------------------------------------------------------------------	
				when EXECUTE2 => 																	-- EXECUTE2
					case opcode is 
						--------- ALU ------------
						when 3 =>																	--3. 16-bit ALU output
							reg(to_integer(unsigned(Rd)+1)) <= std_logic_vector(aluResult(15 downto 8));
							reg(to_integer(unsigned(Rd))) <= std_logic_vector(aluResult(7 downto 0));
							status <= aluS_out;
							state <= EXECUTE1;

						when 8 =>																	--9. 8-bit ALU compare (registers don't change)
							status <= aluS_out;
							state <= EXECUTE1;

						when 9 =>																	--10. 8-bit ALU output (others)
							reg(to_integer(unsigned(Rd))) <= std_logic_vector(aluResult(7 downto 0));
							status <= aluS_out;
							state <= EXECUTE1;
						--------------------------
						when 11 =>																	--11. CPSE : Compare, skip if Equal
							if reg(to_integer(unsigned(d5))) /= reg(to_integer(unsigned(r5))) then
								pc_inc := 0;
							end if;
							state <= EXECUTE1;
						
						when 28 => 																	--28. LDS : Load Direct from data space 16-bit		
 							d_addr <= instruction(DATAMEM_SIZE-1 downto 0);	-- where in data memory to read from 				
 							pc_inc := 0;
							state <= EXECUTE3;
						
						when 36 =>
							reg(to_integer(unsigned(Rd))) <= s_dr(7 downto 0);
							stack_p <= std_logic_vector(unsigned(stack_p)-1);
							state <= EXECUTE1;
						
 						when 37 => 																	--37. STS  : Store Direct to Data Space 16-bit		
 							d_addr <= instruction(DATAMEM_SIZE-1 downto 0);
							d_dw <= reg(to_integer(unsigned(Rd)));			
 							d_wr <= '1';			
 							state <= EXECUTE1;
 
						when 59 => 																	--59. RET  : Subroutine Return
							pc <= s_dr(PROGMEM_SIZE-1 downto 0);
							stack_p <= std_logic_vector(unsigned(stack_p)-1);
							state <= EXECUTE1;
						
						when 63 =>  																--63. JMP  : Jump
							--immediate address is loaded from prog_mem on this clock cycle.
							pc_inc := to_integer(unsigned(instruction(PROGMEM_SIZE-1 downto 0)) - unsigned(pc));
							state <= EXECUTE1;
						
						when 64 =>  																--64. CALL : Call Subroutine
							--immediate address is loaded from prog_mem on this clock cycle.
							pc_inc := to_integer(unsigned(instruction(PROGMEM_SIZE-1 downto 0)) - unsigned(pc));
							state <= EXECUTE1;
						
						when 80 =>																	--80. Insert hole in pipeline
							state <= EXECUTE1;
						
						when others  => 
							state <= EXECUTE1;
					end case;
				------------------------------------------------------------------------------------	
				when EXECUTE3 => 
					case opcode is
						when 28 => 																	--28. LDS : Load Direct from data space 16-bit		
 							reg(to_integer(unsigned(Rd))) <= d_dr;
 							state <= EXECUTE1;
							
 						when others  => 		
 							state <= EXECUTE1;		
 					end case;
				------------------------------------------------------------------------------------	
				when HALT => 
					NULL;
				------------------------------------------------------------------------------------	
			end case;
			--move program counter every clock cycle.
			if (pc_inc < 0) then
				pc <= std_logic_vector( unsigned(pc) - pc_inc - 1);
			else
				pc <= std_logic_vector( unsigned(pc) + pc_inc );
			end if;
		end if;
	end process cpu_state_machine;
	

end architecture ATMEGA_CPU;