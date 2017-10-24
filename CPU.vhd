library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port(
		RESET			: in  std_logic;
		CLK 			: in  std_logic
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
	shared variable VRd		: std_logic_vector(4 downto 0);
	shared variable VRr		: std_logic_vector(4 downto 0);
	
	signal opcode		: integer range 0 to 255;
	
	signal aluA			: std_logic_vector(15 downto 0);
	signal aluB			: std_logic_vector(7 downto 0);
	signal aluControl : std_logic_vector(4 downto 0);
	signal aluS_in		: std_logic_vector(7 downto 0);
	signal aluS_out	: std_logic_vector(7 downto 0);
	signal aluResult	: std_logic_vector(15 downto 0);
	
	type cpu_states is (EXECUTE1, EXECUTE2, EXECUTE3, EXECUTE4, EXECUTE5, HALT);
	signal state: cpu_states := EXECUTE1;
	
	alias pc 				: std_logic_vector(PROGMEM_SIZE-1 downto 0) 	is p_addr;
	alias instruction 	: std_logic_vector(15 downto 0) 				is p_dr;
	
	shared variable pc_inc  : integer := 1;
	
	shared variable d5		: std_logic_vector(4 downto 0);
	shared variable d4		: std_logic_vector(3 downto 0);
	shared variable d3		: std_logic_vector(2 downto 0);
	shared variable r5		: std_logic_vector(4 downto 0);
	shared variable r4		: std_logic_vector(3 downto 0);
	shared variable r3		: std_logic_vector(2 downto 0);
	shared variable imm12   : std_logic_vector(11 downto 0);
	shared variable imm8		: std_logic_vector(7 downto 0);
	shared variable imm7		: std_logic_vector(6 downto 0);
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
	
	-- Stack memory: 1 K (words), 16-bit wide, read/write
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
	
	cpu_state_machine: process(CLK, RESET)
	begin
		if RESET = '1' then
			pc <= (others => '0'); -- reset program counter
			status <= (others => '0');
			reg <= ((others=> (others=>'0')));
			stack_p <= (others => '1');
			
			-- reset everything, data memory, stack, other registers, etc.
		elsif rising_edge(CLK) then
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
													
												when "11" =>
													i2 := instruction(7) & instruction(3);
													case i2 is
														when "00" => 								--04. MULSU  : Multiply Signed with Unsigned
															
														when "10" => 								--05. FMULS  : Fractional Multiply Signed
															
														when "01" => 								--06. FMUL   : Fractional Multiply Unsigned
															
														when "11" => 								--07. FMULSU : Fractional Multiply Signed with Unsigned
															
														when others => -- NOP
															NULL;
													end case;
												when others => -- NOP
													NULL;
											end case;
										when "01" => 												--08. CPC  : Compare with Carry
											
										when "10" => 												--09. SBC  : Subtract with Carry
											
										when "11" => 												--10. ADD  : Add without Carry
											
										when others => -- NOP
											NULL;
									end case;
								when "001" =>
									case instruction(11 downto 10) is
										when "00" => 												--11. CPSE : Compare, skip if Equal
											if d5 = r5 then
												pc_inc := 2;
											end if;
											
										when "01" => 												--12. CP   : Compare
											
										when "10" => 												--13. SUB  : Subtract without Carry
											
										when "11" => 												--14. ADC  : Add with Carry
											
										when others => -- NOP
											NULL;
									end case;
								when "010" =>
									case instruction(11 downto 10) is
										when "00" => 												--15. AND  : Logical AND 
											
										when "01" => 												--16. EOR  : Exclusive OR
											
										when "10" => 												--17. OR   : Logical OR
											
										when "11" => 												--18. MOV  : Copy Register
											reg(to_integer(unsigned(Rd)))<=reg(to_integer(unsigned(Rr)));
											
										when others => -- NOP
											NULL;
									end case;
								when "011" => 														--19. CPI  : Compare with Immediate
									
								when "100" => 														--20. SBCI : Subtract Immediate with Carry
									
								when "101" => 														--21. SUBI : Subtract Immediate
									
								when "110" => 														--22. ORI  : Logical OR with Immediate
									
								when "111" => 														--23. ANDI : Logical AND with Immediate
									
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
															state <= EXECUTE2;	
														when "1100" => 								--29. LD  : Load Indirect X
															
														when "0010" => 								--30. LD  : Load Indirect Z and Pre Decrement
															
														when "1010" => 								--31. LD  : Load Indirect Y and Pre Decrement
															
														when "1110" => 								--32. LD  : Load Indirect X and Pre Decrement
															
														when "0001" => 								--33. LD  : Load Indirect Z and Post Increment
															
														when "1001" => 								--34. LD  : Load Indirect Y and Post Increment
															
														when "1101" => 								--35. LD  : Load Indirect X and Post Increment
															
														when "1111" => 								--36. POP : Pop Register from Stack
															
														when others => -- NOP
															NULL;
													end case;
												when "01" => 
													case i4 is
														when "0000" => 								--37. STS  : Store Direct to Data Space 16-bit
															opcode <= 37;
															state <= EXECUTE2;
														when "1111" => 								--38. PUSH : Push Register on Stack
															
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
															
														when "0001" => 								--51. NEG  : Two’s Complement
															
														when "0010" => 								--52. SWAP : Swap Nibbles 
															
														when "0011" => 								--53. INC  : Increment
															
														when "0101" => 								--54. ASR  : Arithmetic Shift Right
															
														when "0110" => 								--55. LSR  : Logical Shift Right
															
														when "0111" => 								--56. ROR  : Rotate Right Through Carry
															
														when "1000" =>
															case instruction(8 downto 7) is
																when "00" => 						--57. BSET : Flag Set
																	bnum := instruction(6 downto 4);
																	status(to_integer(unsigned(bnum))) <= '1'; 
																	
																when "01" => 						--58. BCLR : Flag Clear
																	
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
															
														when others => -- NOP
															NULL;
													end case;
													case instruction(3 downto 1) is
														when "110" => 								--63. JMP  : Jump
															opcode <= 63;
															-- we have only 64k (16bit) of addressable memory, so the 6 bits of address here are ignored.
															state <= EXECUTE2;
															
														when "111" => 								--64. CALL : Call Subroutine
															s_addr <= stack_p;
															s_dw <= ZEROS(15 downto PROGMEM_SIZE) & std_logic_vector( unsigned(pc) + 2);
															stack_p <= std_logic_vector( unsigned(stack_p) + 1 );
															opcode <= 64;
															state <= EXECUTE2;
															
														when others => -- NOP
															NULL;
													end case;
												when "11" =>
													case instruction(8) is
														when '0' => 								--65. ADIW : Add Immediate to Word
															
														when '1' => 								--66. SBIW : Subtract Immediate from Word
															
														when others => -- NOP
															NULL;
													end case;
												when others => -- NOP
													NULL;
											end case;
										when '1' => 												--67. MUL  : Multiply Unsigned
											
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
											if status(to_integer(unsigned(bnum))) = '1' then
												pc_inc := to_integer(signed(imm7)) + 1;
											end if;
											
										when "01" => 												--78. BRBC : Branch if Status Flag Cleared
											if status(to_integer(unsigned(bnum))) = '0' then
												pc_inc := to_integer(signed(imm7)) + 1;
											end if;
											
										when "11" =>
											case instruction(9) is
												when '0' => 										--79. SBRC : Skip if Bit in Register Cleared
													if reg(to_integer(unsigned(r5)))(to_integer(unsigned(bnum))) = '0' then
														pc_inc := 1;
													end if;
													
												when '1' => 										--80. SBRS : Skip if Bit in Register Set
													if reg(to_integer(unsigned(r5)))(to_integer(unsigned(bnum))) = '1' then
														pc_inc := 1;
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
						when 28 => 																	--28. LDS : Load Direct from data space 16-bit
							d_addr <= instruction(DATAMEM_SIZE-1 downto 0);				-- where in data memory to read from 
							pc_inc := -1;
							state <= EXECUTE3;
						when 37 => 																	--37. STS  : Store Direct to Data Space 16-bit
							d_addr <= instruction(DATAMEM_SIZE-1 downto 0);				
							d_wr <= '1';
							pc_inc := -1;
							state <= EXECUTE3;
						
						when 59 => 																	--59. RET  : Subroutine Return
							pc <= s_dr(PROGMEM_SIZE-1 downto 0);
							stack_p <= std_logic_vector(unsigned(stack_p)-1);
							state <= EXECUTE1;
						
						when 63 =>  																--63. JMP  : Jump
							--immediate address is loaded from prog_mem on this clock cycle.
							pc <= p_dr(PROGMEM_SIZE-1 downto 0);
							state <= EXECUTE1;
						
						when 64 =>  																--64. CALL : Call Subroutine
							pc <= p_dr(PROGMEM_SIZE-1 downto 0);
							state <= EXECUTE1;
						
						when others  => 
							state <= EXECUTE1;
					end case;
				------------------------------------------------------------------------------------	
				when EXECUTE3 => 
					case opcode is
					when 28 => 																	--28. LDS : Load Direct from data space 16-bit
							d_addr <= instruction(DATAMEM_SIZE-1 downto 0);			-- where in data memory to read from 
							reg(to_integer(unsigned(d5)))<=d_dr;
							pc_inc := 2;
							state <= EXECUTE1;
					when 37 => 																	--28. LDS : Load Direct from data space 16-bit
							d_addr <= instruction(DATAMEM_SIZE-1 downto 0);			-- where in data memory to read from 
							d_dw<=reg(to_integer(unsigned(d5)));
							pc_inc := 2;
							d_wr <= '0';
							state <= EXECUTE1;
							when others  => 
							state <= EXECUTE1;
					end case;
				------------------------------------------------------------------------------------	
				when EXECUTE4 => 
					state <= EXECUTE1;
				------------------------------------------------------------------------------------	
				when EXECUTE5 => 
					state <= EXECUTE1;
				------------------------------------------------------------------------------------	
				when HALT => 
					NULL;
				------------------------------------------------------------------------------------	
			end case;
			--move program counter every clock cycle.
			pc <= std_logic_vector( unsigned(pc) + pc_inc );
		end if;
	end process cpu_state_machine;
	

end architecture ATMEGA_CPU;