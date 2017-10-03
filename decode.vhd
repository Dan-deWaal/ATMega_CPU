library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decode is
    Port ( clock : in  STD_LOGIC;
           I_dataInst : in  STD_LOGIC_VECTOR (15 downto 0);
           I_en : in  STD_LOGIC;
           Rd : out  STD_LOGIC_VECTOR (4 downto 0);
           Rr : out  STD_LOGIC_VECTOR (4 downto 0);
           Offset : out  STD_LOGIC_VECTOR (7 downto 0);  --q 
           imm : out  STD_LOGIC_VECTOR (15 downto 0);     --k or A
			  pre_dec: out std_LOGIC;			--   -
			  post_dec: out std_LOGIC;			--   +
			  status  : out std_LOGIC_VECTOR(7 downto 0);  --s
			  bits: out std_LOGIC_VECTOR(2 downto 0);		  --b
			  Any_value: out std_LOGIC_VECTOR(7 downto 0);	--x  #39
           opcode : out  STD_LOGIC_VECTOR (7 downto 0));
end decode;
 
architecture Behavioral of decode is


begin
 
  process (clock)
  begin
    if rising_edge(clock) then 	
		if I_en = '1' then
      --imm <= I_dataInst(7 downto 0) & I_dataInst(7 downto 0);
     -- Opcode <= I_dataInst(15 downto 8);
 
      case I_dataInst(15 downto 0) is
				when "0000000000000000" =>									
					opcode <= std_LOGIC_VECTOR(to_unsigned(1,8));	--1.NOP 
				
				when "00000001--------" =>									
					Rd <= i_dataInst(7 downto 4); 
					Rr <= i_dataInst(3 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(2,8));		--2.MOVW
				
				when "00000010--------" =>
					Rd <= i_dataInst(7 downto 4); 
					Rr <= i_dataInst(3 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(3,8));		--3.MULS
				
				when "000000110---0---" =>
					Rd <= i_dataInst(6 downto 4); 
					Rr <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(4,8));		--4.MULSU
				
				when "000000110---1---" =>
					Rd <= i_dataInst(6 downto 4); 
					Rr <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(5,8));		--5.FMUL
					
				when "000000111---0---" =>
					Rd <= i_dataInst(6 downto 4); 
					Rr <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(6,8));		--6.FMULS
				
				when "000000111---1---" =>
					Rd <= i_dataInst(6 downto 4); 
					Rr <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(7,8));		--7.FMULSU
									
				when "000001----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(8,8));		--8.CPC
				
				when "000010----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(9,8));		--9.SBC	
				
				when "000011----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(10,8));	--10.ADD	
				
				when "000100----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(11,8));	--11.CPSE
					
				when "000101----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(12,8));	--12.CP
					
				when "000110----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(13,8));	--13.SUB
									
				when "000111----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(14,8));	--14.ADC
					
				when "001000----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(15,8));	--15.AND
					
				when "001001----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(16,8));	--16.EOR
					
				when "001010----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(17,8));	--17.OR
					
				when "001011----------" =>
					Rd <= i_dataInst(8 downto 4); 
					Rr <= i_dataInst(3 downto 0) & i_dataInst(9);
					opcode <=std_LOGIC_VECTOR(to_unsigned(18,8));	--18.MOV
					
				when "0011------------" =>
					Rd <= i_dataInst(7 downto 4); 
					imm <= i_dataInst(3 downto 0) & i_dataInst(11 downto 8);
					opcode <=std_LOGIC_VECTOR(to_unsigned(19,8));	--19.CPI
				
				when "0100------------" =>
					Rd <= i_dataInst(7 downto 4); 
					imm <= i_dataInst(3 downto 0) & i_dataInst(11 downto 8);
					opcode <=std_LOGIC_VECTOR(to_unsigned(20,8));	--20.SBCI
					
				when "0101------------" =>
					Rd <= i_dataInst(7 downto 4); 
					imm <= i_dataInst(3 downto 0) & i_dataInst(11 downto 8);
					opcode <=std_LOGIC_VECTOR(to_unsigned(21,8));	--21.SUBI
					
				when "0110------------" =>
					Rd <= i_dataInst(7 downto 4); 
					imm <= i_dataInst(3 downto 0) & i_dataInst(11 downto 8);
					opcode <=std_LOGIC_VECTOR(to_unsigned(22,8));	--22.ORI
					
				when "0111------------" =>
					Rd <= i_dataInst(7 downto 4); 
					imm <= i_dataInst(3 downto 0) & i_dataInst(11 downto 8);
					opcode <=std_LOGIC_VECTOR(to_unsigned(23,8));	--23.ANDI
					
				when "1000000-----0000" =>
					Rd <= i_dataInst(8 downto 4); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(24,8));	--24.LD Z
					
				when "1000000-----1000" =>
					Rd <= i_dataInst(8 downto 4); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(25,8));	--25.LD Y
					
				when "10-0--0-----0---" =>
					Rd <= i_dataInst(8 downto 4);
					offset<= i_dataInst(2 downto 0) & i_dataInst(11 downto 10) & i_dataInst(13);
					opcode <=std_LOGIC_VECTOR(to_unsigned(26,8));	--26.LDD Z
					
				when "10-0--0-----1---" =>
					Rd <= i_dataInst(8 downto 4);
					offset<= i_dataInst(2 downto 0) & i_dataInst(11 downto 10) & i_dataInst(13);
					opcode <=std_LOGIC_VECTOR(to_unsigned(27,8));	--27.LDD Y
					
				when "10-0--1-----0---" =>			
					Rr <= i_dataInst(8 downto 4);
					offset<= i_dataInst(2 downto 0) & i_dataInst(11 downto 10) & i_dataInst(13);
					opcode <=std_LOGIC_VECTOR(to_unsigned(28,8));	--28.STD Z+q,Rr (Wrong, r replace d)
					
				when "10-0--1-----1---" =>
					Rr <= i_dataInst(8 downto 4);
					offset<= i_dataInst(2 downto 0) & i_dataInst(11 downto 10) & i_dataInst(13);
					opcode <=std_LOGIC_VECTOR(to_unsigned(29,8));	--29.STD Y (wrong) 
					
				when "1001000-----0000" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(30,8));	--30.LDS *
					
				when "1001000-----00--" =>
					Rd <= i_dataInst(8 downto 4);
					PRE_dec<= i_dataInst(1);		--  -
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(31,8));	--31.LD -Z+
				
				when "1001000-----010-" =>
					Rd <= i_dataInst(8 downto 4);
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(32,8));	--32.LPM Z
				
				when "1001000-----011-" =>
					Rd <= i_dataInst(8 downto 4);
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(33,8));	--33.ELPM Z
					
				when "1001000-----10--" =>
					Rd <= i_dataInst(8 downto 4);
					PRE_dec<= i_dataInst(1);		--  -
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(34,8));	--34.LD -Y+
					
				when "1001000-----11--" =>
					Rd <= i_dataInst(8 downto 4);
					PRE_dec<= i_dataInst(1);		--  -
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(35,8));	--35.LD X
					
				when "1001000-----1111" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(36,8));	--36.POP
					
				when "1001001-----0000" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(37,8));	--37.STS *(Wrong d replace r)
					
				when "1001001-----00--" =>
					Rr <= i_dataInst(8 downto 4);
					PRE_dec<= i_dataInst(1);		--  -
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(38,8));	--38.ST -z+
					
				when "1001001-----01--" =>
					Rr <= i_dataInst(8 downto 4);
					Any_value<= i_dataInst(1 downto 0);		
					opcode <=std_LOGIC_VECTOR(to_unsigned(39,8));	--39. ??? XCH,LAC,LAS,LAT
					
				when "1001001-----10--" =>
					Rr <= i_dataInst(8 downto 4);
					PRE_dec<= i_dataInst(1);		--  -
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(40,8));	--40. ST -Y+
					
				when "1001001-----11--" =>
					Rr <= i_dataInst(8 downto 4);
					PRE_dec<= i_dataInst(1);		--  -
					post_dec<= i_dataInst(0);		--  +
					opcode <=std_LOGIC_VECTOR(to_unsigned(41,8));	--41.ST X
					
				when "1001001-----1111" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(42,8));	--42.PUSH
					
				when "1001010-----0000" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(43,8));	--43.COM
					
				when "1001010-----0001" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(44,8));	--44.NEG
				
				when "1001010-----0010" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(45,8));	--45.SWAP
					
				when "1001010-----0011" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(46,8));	--46.INC
					
				when "1001010-----0100" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(47,8));	--47.??? (Wrong,no command)
					
				when "1001010-----0101" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(48,8));	--48.ASR
					
				when "1001010-----0110" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(49,8));	--49.LSR
					
				when "1001010-----0111" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(50,8));	--50.ROR
					
				when "1001010-----1010" =>
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(51,8));	--51.DEC
					
				when "100101000---1000" =>
					status<= i_dataInst(6 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(52,8));	--52.BSET
					
				when "100101001---1000" =>
					status<= i_dataInst(6 downto 4);
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
					
				when "1001010111111000" =>
					opcode <=std_LOGIC_VECTOR(to_unsigned(66,8));	--66.ESPM (No command)
					
				when "1001010-----110-" =>
					imm <= i_dataInst(8 downto 4) & i_dataInst(0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(67,8));	--67.JMP *
					
				when "1001010-----111-" =>
					imm <= i_dataInst(8 downto 4) & i_dataInst(0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(68,8));	--68.CALL*
					
				when "10010110--------" =>
					imm <= i_dataInst(7 downto 6) & i_dataInst(3 downto 0);
					Rd <= i_dataInst(5 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(69,8));	--69.ADIW
					
				when "10010111--------" =>
					imm <= i_dataInst(7 downto 6) & i_dataInst(3 downto 0);
					Rd <= i_dataInst(5 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(70,8));	--70.SBIW
					
				when "10011000--------" =>
					imm <= i_dataInst(7 downto 3);
					bits <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(71,8));	--71.CBI
					
				when "10011001--------" =>
					imm <= i_dataInst(7 downto 3);
					bits <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(72,8));	--72.SBIC
					
				when "10011010--------" =>
					imm <= i_dataInst(7 downto 3);
					bits <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(73,8));	--73.SBI
					
				when "10011011--------" =>
					imm <= i_dataInst(7 downto 3);
					bits <= i_dataInst(2 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(74,8));	--74.SBIS
				
				when "100111----------" =>
					Rr <= i_dataInst(9) & i_dataInst(3 downto 0);
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(75,8));	--75.MUL 
					
				when "10110-----------" =>
					imm <= i_dataInst(10 downto 9) & i_dataInst(3 downto 0);
					Rd <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(76,8));	--76.IN
					
				when "10111-----------" =>
					imm <= i_dataInst(10 downto 9) & i_dataInst(3 downto 0);
					Rr <= i_dataInst(8 downto 4);
					opcode <=std_LOGIC_VECTOR(to_unsigned(77,8));	--77.OUT
					
				when "1100------------" =>
					imm <= i_dataInst(11 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(78,8));	--78.RJMP
				
				when "1101------------" =>
					imm <= i_dataInst(11 downto 0);
					opcode <=std_LOGIC_VECTOR(to_unsigned(79,8));	--79.RCALL
					
				when "1110------------" =>
					imm <= i_dataInst(11 downto 8) & i_dataInst(3 downto 0);
					Rd <= i_dataInst(7 downto 4); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(80,8));	--80.LDI
					
				when "111100----------" =>
					imm <= i_dataInst(9 downto 3);
					status <= i_dataInst(3 downto 0); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(81,8));	--81.BRBS
					
				when "111101----------" =>
					imm <= i_dataInst(9 downto 3);
					status <= i_dataInst(3 downto 0); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(82,8));	--82.BRBC
					
				when "1111100-----0---" =>
					Rd <= i_dataInst(8 downto 4);
					bits <= i_dataInst(2 downto 0); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(83,8));	--83.BLD	
					
				when "1111101-----0---" =>
					Rd <= i_dataInst(8 downto 4);
					bits <= i_dataInst(2 downto 0); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(84,8));	--84.BST
					
				when "1111110-----0---" =>
					Rr <= i_dataInst(8 downto 4);
					bits <= i_dataInst(2 downto 0); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(85,8));	--85.SBRC
					
				when "1111111-----0---" =>
					Rr <= i_dataInst(8 downto 4);
					bits <= i_dataInst(2 downto 0); 
					opcode <=std_LOGIC_VECTOR(to_unsigned(86,8));	--86.SBRS
				
				when others  => opcode <= (others => '0');
       
      end case;
		end if;
    end if;
  end process;
 
end Behavioral;