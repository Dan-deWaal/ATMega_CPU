library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port(
		PORT_A : std_logic_vector(7 downto 0);
		CLK	 :	std_logic
	);
end entity CPU;

architecture ATMEGA_CPU of CPU is
	constant PROGMEM_SIZE : integer := 12; --4 kb
	constant DATAMEM_SIZE : integer := 16; --64 kb
	
	component mem
		generic (RamWidth  : integer := 8;
					AddrWidth : integer := 10);
		port(
			clock : in std_logic;
			wr		: in std_logic;
			addr	: in std_logic_vector(AddrWidth-1 downto 0);
			dw		: in std_logic_vector(RamWidth-1 downto 0);
			dr		: out std_logic_vector(RamWidth-1 downto 0) );
	end component;	

	signal PA_IO 	: std_logic_vector(7 downto 0);
	
	signal clock	: std_logic;
	
	signal p_wr		: std_logic;
	signal p_addr	: std_logic_vector(PROGMEM_SIZE-1 downto 0);
	signal p_dw		: std_logic_vector(15 downto 0);
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
begin
	clock <= CLK;
	
	-- Create components
	prog_mem : mem generic map (AddrWidth => PROGMEM_SIZE, RamWidth => 16) port map (clock, p_wr, p_addr, p_dw, p_dr);
	data_mem : mem generic map (AddrWidth => DATAMEM_SIZE) port map (clock, d_wr, d_addr, d_dw, d_dr);
	
	cpu_state_machine: process(CLK)
	begin
		if rising_edge(CLK) then
			case state is
				when FETCH => 
					--new instruction is available at p_dr at the end of this clock cycle.
					state <= EXECUTE1;
				when EXECUTE1 => 
					case instruction is
						when "0000000000000000" =>									--1.NOP
							pc <= std_logic_vector( unsigned(pc) + 1 );
							state <=FETCH;
					
						when "00000001--------" =>									--2.MOVW – Copy Register Word
							Rd <= instruction(7 downto 4); 
							Rr <= instruction(3 downto 0);
							reg(to_integer(unsigned(Rd))) <= reg(to_integer(unsigned(Rr)));
							reg(to_integer(unsigned(Rd))+1) <= reg(to_integer(unsigned(Rr))+1);
							state <= FETCH;	
						
						when "00000010--------" =>									--3.MULS – Multiply Signed
							Rd <= instruction(7 downto 4); 
							Rr <= instruction(3 downto 0);
							aluB <= reg(to_integer(unsigned(Rd)));
							aluA <= std_logic_vector(resize(signed(reg(to_integer(unsigned(Rr)))), 16));
							aluControl <= "01011";
							aluS_in <= status;
							state <= EXECUTE2;		
						
						when "000000110---0---" =>
							Rd <= instruction(6 downto 4); 
							Rr <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(4,8));		--4.MULSU
						
						when "000000110---1---" =>
							Rd <= instruction(6 downto 4); 
							Rr <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(5,8));		--5.FMUL
							
						when "000000111---0---" =>
							Rd <= instruction(6 downto 4); 
							Rr <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(6,8));		--6.FMULS
						
						when "000000111---1---" =>
							Rd <= instruction(6 downto 4); 
							Rr <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(7,8));		--7.FMULSU
											
						when "000001----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(8,8));		--8.CPC
						
						when "000010----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(9,8));		--9.SBC	
						
						when "000011----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(10,8));	--10.ADD	
						
						when "000100----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(11,8));	--11.CPSE
							
						when "000101----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(12,8));	--12.CP
							
						when "000110----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(13,8));	--13.SUB
											
						when "000111----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(14,8));	--14.ADC
							
						when "001000----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(15,8));	--15.AND
							
						when "001001----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(16,8));	--16.EOR
							
						when "001010----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(17,8));	--17.OR
							
						when "001011----------" =>
							Rd <= instruction(8 downto 4); 
							Rr <= instruction(3 downto 0) & instruction(9);
							opcode <=std_LOGIC_VECTOR(to_unsigned(18,8));	--18.MOV
							
						when "0011------------" =>
							Rd <= instruction(7 downto 4); 
							imm <= instruction(3 downto 0) & instruction(11 downto 8);
							opcode <=std_LOGIC_VECTOR(to_unsigned(19,8));	--19.CPI
						
						when "0100------------" =>
							Rd <= instruction(7 downto 4); 
							imm <= instruction(3 downto 0) & instruction(11 downto 8);
							opcode <=std_LOGIC_VECTOR(to_unsigned(20,8));	--20.SBCI
							
						when "0101------------" =>
							Rd <= instruction(7 downto 4); 
							imm <= instruction(3 downto 0) & instruction(11 downto 8);
							opcode <=std_LOGIC_VECTOR(to_unsigned(21,8));	--21.SUBI
							
						when "0110------------" =>
							Rd <= instruction(7 downto 4); 
							imm <= instruction(3 downto 0) & instruction(11 downto 8);
							opcode <=std_LOGIC_VECTOR(to_unsigned(22,8));	--22.ORI
							
						when "0111------------" =>
							Rd <= instruction(7 downto 4); 
							imm <= instruction(3 downto 0) & instruction(11 downto 8);
							opcode <=std_LOGIC_VECTOR(to_unsigned(23,8));	--23.ANDI
							
						when "1000000-----0000" =>
							Rd <= instruction(8 downto 4); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(24,8));	--24.LD Z
							
						when "1000000-----1000" =>
							Rd <= instruction(8 downto 4); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(25,8));	--25.LD Y
							
						when "10-0--0-----0---" =>
							Rd <= instruction(8 downto 4);
							offset<= instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
							opcode <=std_LOGIC_VECTOR(to_unsigned(26,8));	--26.LDD Z
							
						when "10-0--0-----1---" =>
							Rd <= instruction(8 downto 4);
							offset<= instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
							opcode <=std_LOGIC_VECTOR(to_unsigned(27,8));	--27.LDD Y
							
						when "10-0--1-----0---" =>			
							Rr <= instruction(8 downto 4);
							offset<= instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
							opcode <=std_LOGIC_VECTOR(to_unsigned(28,8));	--28.STD Z+q,Rr 
							
						when "10-0--1-----1---" =>
							Rr <= instruction(8 downto 4);
							offset<= instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
							opcode <=std_LOGIC_VECTOR(to_unsigned(29,8));	--29.STD Y 
							
						when "1001000-----0000" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(30,8));	--30.LDS *
							
						when "1001000-----00--" =>
							Rd <= instruction(8 downto 4);
							PRE_dec<= instruction(1);		--  -
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(31,8));	--31.LD -Z+
						
						when "1001000-----010-" =>
							Rd <= instruction(8 downto 4);
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(32,8));	--32.LPM Z
						
						when "1001000-----011-" =>
							Rd <= instruction(8 downto 4);
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(33,8));	--33.ELPM Z
							
						when "1001000-----10--" =>
							Rd <= instruction(8 downto 4);
							PRE_dec<= instruction(1);		--  -
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(34,8));	--34.LD -Y+
							
						when "1001000-----11--" =>
							Rd <= instruction(8 downto 4);
							PRE_dec<= instruction(1);		--  -
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(35,8));	--35.LD X
							
						when "1001000-----1111" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(36,8));	--36.POP
							
						when "1001001-----0000" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(37,8));	--37.STS *
							
						when "1001001-----00--" =>
							Rr <= instruction(8 downto 4);
							PRE_dec<= instruction(1);		--  -
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(38,8));	--38.ST -z+
							
						when "000111----------" =>
							Rd <= instruction(4 downto 0);		
							opcode <=std_LOGIC_VECTOR(to_unsigned(39,8));	--39. ROL
							
						when "1001001-----10--" =>
							Rr <= instruction(8 downto 4);
							PRE_dec<= instruction(1);		--  -
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(40,8));	--40. ST -Y+
							
						when "1001001-----11--" =>
							Rr <= instruction(8 downto 4);
							PRE_dec<= instruction(1);		--  -
							post_dec<= instruction(0);		--  +
							opcode <=std_LOGIC_VECTOR(to_unsigned(41,8));	--41.ST X
							
						when "1001001-----1111" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(42,8));	--42.PUSH
							
						when "1001010-----0000" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(43,8));	--43.COM
							
						when "1001010-----0001" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(44,8));	--44.NEG
						
						when "1001010-----0010" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(45,8));	--45.SWAP
							
						when "1001010-----0011" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(46,8));	--46.INC
							
						when "000011----------" =>
							Rd <= instruction(4 downto 0);		
							opcode <=std_LOGIC_VECTOR(to_unsigned(47,8));	--47.LSL
							
						when "1001010-----0101" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(48,8));	--48.ASR
							
						when "1001010-----0110" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(49,8));	--49.LSR
							
						when "1001010-----0111" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(50,8));	--50.ROR
							
						when "1001010-----1010" =>
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(51,8));	--51.DEC
							
						when "100101000---1000" =>
							status<= instruction(6 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(52,8));	--52.BSET
							
						when "100101001---1000" =>
							status<= instruction(6 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(53,8));	--53.BCLR
							
						when "1001010000001001" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(54,8));	--54.IJMP
							
						when "1001010000011001" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(55,8));	--55.EIJMP
							
						when "1001010100001000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(56,8));	--56.RET
							
						when "1001010100001001" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(57,8));	--57.ICALL
						
						when "1001010100011000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(58,8));	--58.RETI
							
						when "1001010100011001" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(59,8));	--59.EICALL
							
						when "1001010110001000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(60,8));	--60.SLEEP
							
						when "1001010110011000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(61,8));	--61.BREAK
							
						when "1001010110101000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(62,8));	--62.WDR
							
						when "1001010111001000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(63,8));	--63.LPM
						
						when "1001010111011000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(64,8));	--64.ELPM
							
						when "1001010111101000" =>
							opcode <=std_LOGIC_VECTOR(to_unsigned(65,8));	--65.SPM
							
						when "001000----------" =>
							Rd <= instruction(4 downto 0);		
							opcode <=std_LOGIC_VECTOR(to_unsigned(66,8));	--66.TST
							
						when "1001010-----110-" =>
							imm <= instruction(8 downto 4) & instruction(0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(67,8));	--67.JMP *
							
						when "1001010-----111-" =>
							imm <= instruction(8 downto 4) & instruction(0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(68,8));	--68.CALL*
							
						when "10010110--------" =>
							imm <= instruction(7 downto 6) & instruction(3 downto 0);
							Rd <= instruction(5 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(69,8));	--69.ADIW
							
						when "10010111--------" =>
							imm <= instruction(7 downto 6) & instruction(3 downto 0);
							Rd <= instruction(5 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(70,8));	--70.SBIW
							
						when "10011000--------" =>
							imm <= instruction(7 downto 3);
							bits <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(71,8));	--71.CBI
							
						when "10011001--------" =>
							imm <= instruction(7 downto 3);
							bits <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(72,8));	--72.SBIC
							
						when "10011010--------" =>
							imm <= instruction(7 downto 3);
							bits <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(73,8));	--73.SBI
							
						when "10011011--------" =>
							imm <= instruction(7 downto 3);
							bits <= instruction(2 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(74,8));	--74.SBIS
						
						when "100111----------" =>
							Rr <= instruction(9) & instruction(3 downto 0);
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(75,8));	--75.MUL 
							
						when "10110-----------" =>
							imm <= instruction(10 downto 9) & instruction(3 downto 0);
							Rd <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(76,8));	--76.IN
							
						when "10111-----------" =>
							imm <= instruction(10 downto 9) & instruction(3 downto 0);
							Rr <= instruction(8 downto 4);
							opcode <=std_LOGIC_VECTOR(to_unsigned(77,8));	--77.OUT
							
						when "1100------------" =>
							imm <= instruction(11 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(78,8));	--78.RJMP
						
						when "1101------------" =>
							imm <= instruction(11 downto 0);
							opcode <=std_LOGIC_VECTOR(to_unsigned(79,8));	--79.RCALL
							
						when "1110------------" =>
							imm <= instruction(11 downto 8) & instruction(3 downto 0);
							Rd <= instruction(7 downto 4); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(80,8));	--80.LDI
							
						when "111100----------" =>
							imm <= instruction(9 downto 3);
							status <= instruction(3 downto 0); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(81,8));	--81.BRBS
							
						when "111101----------" =>
							imm <= instruction(9 downto 3);
							status <= instruction(3 downto 0); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(82,8));	--82.BRBC
							
						when "1111100-----0---" =>
							Rd <= instruction(8 downto 4);
							bits <= instruction(2 downto 0); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(83,8));	--83.BLD	
							
						when "1111101-----0---" =>
							Rd <= instruction(8 downto 4);
							bits <= instruction(2 downto 0); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(84,8));	--84.BST
							
						when "1111110-----0---" =>
							Rr <= instruction(8 downto 4);
							bits <= instruction(2 downto 0); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(85,8));	--85.SBRC
							
						when "1111111-----0---" =>
							Rr <= instruction(8 downto 4);
							bits <= instruction(2 downto 0); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(86,8));	--86.SBRS
						
						when "1001001-----0010" =>
							Rr <= instruction(8 downto 4); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(87,8));	--87.LAC
							
						when "1001001-----0100" =>
							Rr <= instruction(8 downto 4); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(88,8));	--88.XCH
							
						when "1001001-----0101" =>
							Rr <= instruction(8 downto 4); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(89,8));	--89.LAS
						
						when "1001001-----0111" =>
							Rr <= instruction(8 downto 4); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(90,8));	--90.LAT
						
						when "111100-------001" =>
								imm<= instruction(9 downto 3); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(91,8));	--91.BREQ
						
						when "111100-------000" =>
								imm<= instruction(9 downto 3); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(92,8));	--92.BRLO
							
						when "111101-------001" =>
								imm<= instruction(9 downto 3); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(93,8));	--93.BRNE
							
						when "111101-------100" =>
								imm<= instruction(9 downto 3); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(94,8));	--94.BRGE
							
						when "111100-------100" =>
								imm<= instruction(9 downto 3); 
							opcode <=std_LOGIC_VECTOR(to_unsigned(95,8));	--95.BRLT			
							
						when others  => instruction <= (others => '0');
					end case;
				when EXECUTE2 => 														-- EXECUTE2
					case instruction is
						when "00000010--------" =>									--3.MULS – Multiply Signed
							status <= aluS_out;
							reg(0) <= aluResult(7 downto 0);
							reg(1) <= aluResult(15 downto 8);
							state <= FETCH;
						when others  => instruction <= (others => '0');
					end case;
					state <= FETCH;
				when EXECUTE3 => 
					state <= FETCH;
				when EXECUTE4 => 
					state <= FETCH;
				when EXECUTE5 => 
					state <= FETCH;
				when HALT => 
					NULL;
			end case;
		end if;
	end process cpu_state_machine;
	

end architecture ATMEGA_CPU;