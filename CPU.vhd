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
	constant PROGMEM_SIZE : integer := 12; --4 kb
	constant DATAMEM_SIZE : integer := 16; --64 kb
	--constant STACK_SIZE
	
	signal PA_IO 	: std_logic_vector(7 downto 0); -- remove this
	
	--signal p_wr		: std_logic;
	signal p_addr	: std_logic_vector(PROGMEM_SIZE-1 downto 0);
	--signal p_dw		: std_logic_vector(15 downto 0);
	signal p_dr		: std_logic_vector(15 downto 0);
	
	signal d_wr		: std_logic;
	signal d_addr	: std_logic_vector(DATAMEM_SIZE-1 downto 0);
	signal d_dw		: std_logic_vector(7 downto 0);
	signal d_dr		: std_logic_vector(7 downto 0);
		
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
	shared variable VRr		: std_logic_vector(4 downto 0); --move these into the process
	
	signal opcode		: std_logic_vector(7 downto 0);
	
	signal aluA			: std_logic_vector(15 downto 0);
	signal aluB			: std_logic_vector(7 downto 0);
	signal aluControl : std_logic_vector(4 downto 0);
	signal aluS_in		: std_logic_vector(7 downto 0);
	signal aluS_out	: std_logic_vector(7 downto 0);
	signal aluResult	: std_logic_vector(15 downto 0);
	
	type cpu_states is (FETCH, EXECUTE1, EXECUTE2, EXECUTE3, EXECUTE4, EXECUTE5, HALT);
	signal state: cpu_states := FETCH;
	
	alias pc 			: std_logic_vector(PROGMEM_SIZE-1 downto 0) 	is p_addr;
	alias instruction : std_logic_vector(15 downto 0) 					is p_dr;
	
	signal i_decode : std_logic;
	
	
	shared variable d5		: std_logic_vector(4 downto 0);
	shared variable d4		: std_logic_vector(3 downto 0);
	shared variable d3		: std_logic_vector(2 downto 0);
	shared variable r5		: std_logic_vector(4 downto 0);
	shared variable r4		: std_logic_vector(3 downto 0);
	shared variable r3		: std_logic_vector(2 downto 0);
	shared variable imm12 : std_logic_vector(11 downto 0);
	shared variable imm8	: std_logic_vector(7 downto 0);
	shared variable i2		: std_logic_vector(1 downto 0);
	shared variable i4		: std_logic_vector(3 downto 0);

begin

	-- Program memory: 4 KB, 16-bit wide, read-only
	make_progMem: entity work.mem16
	generic map(
		AddrWidth => PROGMEM_SIZE
	)
	port map(
		clock => CLK,
		addr => p_addr,
		dr => p_dr
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
	
	--make stack memory: ?? KB, ?-bit wide, read/write
	

	
	cpu_state_machine: process(CLK, RESET)
	begin
		if RESET = '1' then
			pc <= (others => '0'); -- reset program counter
			-- reset other registers, eg status.
		elsif rising_edge(CLK) then
			case state is
				when FETCH => 
					--new instruction is available at p_dr at the end of this clock cycle.
					state <= EXECUTE1;
				when EXECUTE1 => 
					d5		:= instruction(8 downto 4);
					d4		:= instruction(7 downto 4);
					d3		:= instruction(6 downto 4);
					r5		:= instruction(9) & instruction(3 downto 0);
					r4		:= instruction(3 downto 0);
					r3		:= instruction(2 downto 0);
					imm12 := instruction(11 downto 0);
					imm8	:= instruction(11 downto 8) & instruction(3 downto 0);

					case instruction(15) is
						when '0' =>
							case instruction(14 downto 12) is
								when "000" =>
									case instruction(11 downto 10) is
										when "00" =>
											case instruction(9 downto 8) is
												when "00" => --01. NOP  : No Operation 
													NULL;
												when "01" => --02. MOVW : Copy Register Pair
												
												when "10" => --03. MULS : Multiply Signed
												
												when "11" =>
													i2 := instruction(7) & instruction(3);
													case i2 is
														when "00" => -- 04. MULSU  : Multiply Signed with Unsigned
														
														when "10" => -- 05. FMULS  : Fractional Multiply Signed
														
														when "01" => -- 06. FMUL   : Fractional Multiply Unsigned
														
														when "11" => -- 07. FMULSU : Fractional Multiply Signed with Unsigned
														
													end case;
											end case;
										when "01" => --08. CPC  : Compare with Carry
										
										when "10" => --09. SBC  : Subtract with Carry
										
										when "11" => --10. ADD  : Add without Carry
										
									end case;
								when "001" =>
									case instruction(11 downto 10) is
										when "00" => --11. CPSE : 
											
										when "01" => --12. CP   : 
										
										when "10" => --13. SUB  :
										
										when "11" => --14. ADC  : 
										
									end case;
								when "010" =>
									case instruction(11 downto 10) is
										when "00" => --15. AND  : 
										
										when "01" => --16. EOR  : 
										
										when "10" => --17. OR   : 
										
										when "11" => --18. MOV  : 
										
									end case;
								when "011" => --19. CPI  : Compare with Immediate

								when "100" => --20. SBCI : Subtract Immediate with Carry
								
								when "101" => --21. SUBI : Subtract Immediate
								
								when "110" => --22. ORI  : Logical OR with Immediate
								
								when "111" => --23. ANDI : Logical AND with Immediate
								
								when others => -- NOP
									NULL;
							end case;
						when '1' =>
							case instruction(14 downto 12) is
								when "000" => 
									i2 := instruction(9) & instruction(3);
									case i2 is
										when "10" => --24. ST  : Store Indirect Z
										
										when "11" => --25. ST  : Store Indirect Y
										
										when "00" => --26. LD  : Load Indirect Y
										
										when "01" => --27. LD  : Load Indirect Z
										
									end case;
								when "001" =>
									case instruction(11) is
										when '0' =>
											i4 := instruction(3 downto 0);
											case instruction(10 downto 9) is
												when "00" => 
													case i4 is
														when "0000" => --28. LDS : Load Direct from data space 16-bit
														
														when "1100" => --29. LD  : Load Indirect X
														
														when "0010" => --30. LD  : Load Indirect Z and Pre Decrement
														
														when "1010" => --31. LD  : Load Indirect Y and Pre Decrement
														
														when "1110" => --32. LD  : Load Indirect X and Pre Decrement
														
														when "0001" => --33. LD  : Load Indirect Z and Post Increment
														
														when "1001" => --34. LD  : Load Indirect Y and Post Increment
														
														when "1101" => --35. LD  : Load Indirect X and Post Increment
														
														when "1111" => --36. POP : Pop Register from Stack
														
														when others => -- NOP
															NULL;
													end case;
												when "01" => 
													case i4 is
														when "0000" => --37. STS  : Store Direct to Data Space 16-bit
														
														when "1111" => --38. PUSH : Push Register on Stack
														
														when "0100" => --39. XCH  : Exchange Z
														
														when "1100" => --40. ST   : Store Indirect X
														
														when "0010" => --41. ST   : Store Indirect Z and Pre Decrement
														
														when "1010" => --42. ST   : Store Indirect Y and Pre Decrement
														
														when "0110" => --43. LAC  : Load and Clear Z
														
														when "1110" => --44. ST   : Store Indirect X and Pre Decrement
														
														when "0001" => --45. ST   : Store Indirect Z and Post Decrement
														
														when "1001" => --46. ST   : Store Indirect Y and Post Decrement
														
														when "0101" => --47. LAS  : Load and Set Z
														
														when "1101" => --48. ST   : Store Indirect X and Post Decrement
														
														when "0111" => --49. LAT  : Load and Toggle Z
														
														when others => -- NOP
															NULL;
													end case;
												when "10" => 
													case i4 is
														when "0000" => --50. COM  : One’s Complement
														
														when "0001" => --51. NEG  : Two’s Complement
														
														when "0010" => --52. SWAP : Swap Nibbles 
														
														when "0011" => --53. INC  : Increment
														
														when "0101" => --54. ASR  : Arithmetic Shift Right
														
														when "0110" => --55. LSR  : Logical Shift Right
														
														when "0111" => --56. ROR  : Rotate Right Through Carry
														
														when "1000" =>
															case instruction(8 downto 7) is
																when "00" => --57. BSET : Flag Set
																
																when "01" => --58. BCLR : Flag Clear
																
																when "10" => --59. RET  : Subroutine Return
																
																when others => -- NOP
																	NULL;
															end case;
														when "1001" =>
															case instruction(8) is
																when '0' => --60. IJMP  : Indirect Jump to (Z)
																
																when '1' => --61. ICALL : Indirect Call to (Z)
																
															end case;
														when "1010" => --62. DEC  : Decrement
														
														when others => -- NOP
															NULL;
													end case;
													case instruction(3 downto 1) is
														when "110" => --63. JMP  : Jump
														
														when "111" => --64. CALL : Call Subroutine
														
														when others => -- NOP
															NULL;
													end case;
												when "11" =>
													case instruction(8) is
														when '0' => --65. ADIW : Add Immediate to Word
														
														when '1' => --66. SBIW : Subtract Immediate from Word
														
													end case;
											end case;
										when '1' => --67. MUL  : Multiply Unsigned
										
									end case;
								when "010" =>
									case instruction(11) is
										when '0' => --68. LDS : Load Direct from data space 7-bit
										
										when '1' => --69. STS : Store Direct to Data Space 7-bit
										
									end case;
								when "100" => --74. RJMP  : Relative Jump 
								
								when "101" => --75. RCALL : Relative Call Subroutine
								
								when "110" => --76. LDI   : Load Immediate
								
								when "111" =>
									case instruction(11 downto 10) is
										when "00" => --77. BRBS : Branch if Status Flag Set
										
										when "01" => --78. BRBC : Branch if Status Flag Cleared
										
										when "11" =>
											case instruction(9) is
												when '0' => --79. SBRC : Skip if Bit in Register Cleared
												
												when '1' => --80. SBRS : Skip if Bit in Register Set
												
											end case;
										when others => -- NOP
											NULL;
									end case;
								when others => -- NOP
									NULL;
							end case;
					end case;

				------------------------------------------------------------------------------------	
				when EXECUTE2 => 														-- EXECUTE2
					case instruction is
						when "00000010--------" =>									--3.MULS – Multiply Signed
							status <= aluS_out;
							reg(0) <= aluResult(7 downto 0);
							reg(1) <= aluResult(15 downto 8);
							state <= FETCH;
						
						when others  => 
							pc <= std_logic_vector( unsigned(pc) + 1 );		--NOP
							state <=FETCH;
					end case;
					state <= FETCH;
				--------------------------------------------------------------------	
				when EXECUTE3 => 
					state <= FETCH;
				--------------------------------------------------------------------	
				when EXECUTE4 => 
					state <= FETCH;
				--------------------------------------------------------------------	
				when EXECUTE5 => 
					state <= FETCH;
				--------------------------------------------------------------------	
				when HALT => 
					NULL;
				--------------------------------------------------------------------	
			end case;
		end if;
	end process cpu_state_machine;
	

end architecture ATMEGA_CPU;