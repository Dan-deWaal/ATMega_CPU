library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decode is
    Port ( clock : in  STD_LOGIC;
           instruction : in  STD_LOGIC_VECTOR (15 downto 0);
           I_en : in  STD_LOGIC;
           Rd : out  STD_LOGIC_VECTOR (4 downto 0);
           Rr : out  STD_LOGIC_VECTOR (4 downto 0);
           Offset : out  STD_LOGIC_VECTOR (7 downto 0);  --q 
           imm : out  STD_LOGIC_VECTOR (15 downto 0);     --k or A
			  pre_dec: out std_LOGIC;			--   -
			  post_dec: out std_LOGIC;			--   +
			  status  : out std_LOGIC_VECTOR(7 downto 0);  --s
			  bits: out std_LOGIC_VECTOR(2 downto 0)		  --b
			  );
			
end decode;
 
architecture Behavioral of decode is


shared variable VRd: std_LOGIC_VECTOR (4 downto 0);
shared variable VRr: std_LOGIC_VECTOR(4 downto 0);

type cpu_states is (FETCH);

signal state: cpu_states := FETCH;



begin
 
  process (clock)
  variable i2: std_LOGIC_VECTOR(1 downto 0);
  variable b2: std_LOGIC_VECTOR(2 downto 0);
  begin
    if rising_edge(clock) then 	
		if I_en = '1' then
 
      case instruction(15 downto 12) is
			when "0000" =>									--1.0000 family 1st bits						
				case instruction(11 downto 8) is 
					when "0000"=> null;				--1.NOP						
					when "0001"=>						--2.MOVW		2nd bits
						VRd := '0' & instruction(7 downto 4); 
						VRr := '0' & instruction(3 downto 0); 
						Rd<=VRd;
						Rr<=VRr;
						state <= FETCH;					
					when "0010"=> 						--3.MULS
						VRd := '0' & instruction(7 downto 4); 
						VRr := '0' & instruction(3 downto 0); 
						Rd<=VRd;
						Rr<=VRr;
						state <= FETCH;
					when "0011"=>
						i2:= instruction (7) & instruction(3);
						case i2 is 		--3rd and 4th bits
							when "00" =>				--	4.MULSU
								VRd := "00" & instruction(6 downto 4); 
								VRr := "00" & instruction(2 downto 0); 
								Rd<=VRd;
								Rr<=VRr;
								state <= FETCH;		
							when "01" =>				--5.FMUL
								VRd := "00" & instruction(6 downto 4); 
								VRr := "00" & instruction(2 downto 0); 
								Rd<=VRd;
								Rr<=VRr;
								state <= FETCH;		
							when "10" =>				--6.FMULS
								VRd := "00" & instruction(6 downto 4); 
								VRr := "00" & instruction(2 downto 0); 
								Rd<=VRd;
								Rr<=VRr;
								state <= FETCH;	
							when "11" =>				--7.FMLSU
								VRd := "00" & instruction(6 downto 4); 
								VRr := "00" & instruction(2 downto 0); 
								Rd<=VRd;
								Rr<=VRr;
								state <= FETCH;	
							end case;
							when others => null; 
						end case;
					case instruction (11 downto 10) is 
						when "01"=>						--8.CPC
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "10"=>						--9.SBC
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "11"=>						--10.ADD
							VRd := instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when others => null;
					end case;	
			when "0001" =>						--Family 2 0001
					case instruction (11 downto 10) is 
						when "00"=>						--11.CPSE
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "01"=>						--12.CP
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "10"=>						--13.SUB
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "11"=>						--14.ADC
							VRd := instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						end case;
				when "0010" =>							--Family 3 0010
					case instruction (11 downto 10) is 
						when "00"=>						--15.AND
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "01"=>						--16.EOR
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "10"=>						--17.OR
							VRd :=  instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						when "11"=>						--18.MOV
							VRd := instruction(8 downto 4); 
							VRr := instruction(9) & instruction(3 downto 0); 
							Rd<=VRd;
							Rr<=VRr;
							state <= FETCH;
						end case;
				when "0011"=>			--F4	19.CPI
					VRd := '0' & instruction(7 downto 4); 
					imm <= "00000000" & instruction(11 downto 8) & instruction(3 downto 0); 
					Rd<=VRd;
					state <= FETCH;
				when "0100"=>			--F5	20.SBCI
					VRd := '0' & instruction(7 downto 4); 
					imm <= "00000000" & instruction(11 downto 8) & instruction(3 downto 0); 
					Rd<=VRd;
					state <= FETCH;
				when "0101"=>			--F6	21.SUBI
					VRd := '0' & instruction(7 downto 4); 
					imm <= "00000000" & instruction(11 downto 8) & instruction(3 downto 0); 
					Rd<=VRd;
					state <= FETCH;
				when "0110"=>			--F7	22.ORI
					VRd := '0' & instruction(7 downto 4); 
					imm <= "00000000" & instruction(11 downto 8) & instruction(3 downto 0); 
					Rd<=VRd;
					state <= FETCH;
				when "0111"=>			--F8	23.ANDI
					VRd := '0' & instruction(7 downto 4); 
					imm <= "00000000" & instruction(11 downto 8) & instruction(3 downto 0); 
					Rd<=VRd;
					state <= FETCH;
				When "1000"=>				--F9
					case instruction (3) is
						when '0'=>		--24.LDZ
							VRd := instruction(8 downto 4); 
							Rd<=VRd;
							state <= FETCH;
						when '1'=>		--25.LDY
							VRd := instruction(8 downto 4); 
							Rd<=VRd;
							state <= FETCH;
					end case;
				when "1001"=>			--F10
					case instruction (11 downto 9) is
						when "000"=>
							case instruction(3 downto 2) is
								when "00" =>
									case instruction(1 downto 0) is
										when "00"=>			--26.LDS*
											VRd := instruction(8 downto 4); 
											Rd<=VRd;
											state <= FETCH;
										when others => 	--27.LD -Z+
											VRd := instruction(8 downto 4);
											PRE_dec<= instruction(1);		
											post_dec<= instruction(0);	
											Rd<=VRd;
											state <= FETCH;
									end case;
								when "01"=>
									case instruction(1) is
										when '0'=>			--28.LPM Z
											VRd := instruction(8 downto 4);
											post_dec<= instruction(0);		
											Rd<=VRd;
											state <= FETCH;
										when '1'=>			--29.ELPM Z 
											VRd := instruction(8 downto 4);
											post_dec<= instruction(0);		
											Rd<=VRd;
											state <= FETCH;
									end case;
								when "10"=>					--30.LD -Y+
									VRd := instruction(8 downto 4);
									PRE_dec<= instruction(1);		
									post_dec<= instruction(0);	
									Rd<=VRd;
									state <= FETCH;
								when "11"=>	
									case instruction(1 downto 0) is
										when "11" =>		--31.POP
											VRd := instruction(8 downto 4);	
											Rd<=VRd;
											state <= FETCH;
										when others =>		--32.LD X
											VRd := instruction(8 downto 4);
											PRE_dec<= instruction(1);		
											post_dec<= instruction(0);	
											Rd<=VRd;
											state <= FETCH;
									end case;	
							end case;
						when "001"=>
							case instruction(3 downto 2) is
								when "00"=>
									case instruction(1 downto 0)is
										when "00"=>			--33.STS*
											VRr := instruction(8 downto 4);	
											Rr<=VRr;
											state <= FETCH;
										when "10"=>			--34.LAC
											VRr := instruction(8 downto 4);	
											Rr<=VRr;
											state <= FETCH;
										when others=>		--35.ST -Z+
											VRr := instruction(8 downto 4);
											PRE_dec<= instruction(1);		
											post_dec<= instruction(0);	
											Rr<=VRr;
											state <= FETCH;
									end case;
								when "01"=>
									case instruction(1 downto 0)is
										when "00"=>			--36.XCH
											VRr := instruction(8 downto 4);	
											Rr<=VRr;
											state <= FETCH;
										when "01"=>			--37.LAS
											VRr := instruction(8 downto 4);	
											Rr<=VRr;
											state <= FETCH;
										when "11"=>			--38.LAT
											VRr := instruction(8 downto 4);	
											Rr<=VRr;
											state <= FETCH;
										when others=>null;
									end case;
								when "10"=>					--39.ST -Y+
									VRr := instruction(8 downto 4);
									PRE_dec<= instruction(1);		
									post_dec<= instruction(0);	
									Rr<=VRr;
									state <= FETCH;
								when "11"=>
									case instruction(1 downto 0)is
										when "11"=>			--40.PUSH
											VRd := instruction(8 downto 4);	
											Rd<=VRd;
											state <= FETCH;
										when others=>		--41.ST X
											VRr := instruction(8 downto 4);
											PRE_dec<= instruction(1);		
											post_dec<= instruction(0);	
											Rr<=VRr;
											state <= FETCH;
									end case;
							end case;
						when "010"=>
							case instruction(8) is
								when '0'=>
									case instruction(7) is
										when '0'=>
											case instruction(4) is
												when '0'=>		--42.IJMP
													state <= FETCH;
												when '1'=>		--43.EIJMP
													state <= FETCH;
												when others=>	--44.BSET
													status<= "00000" & instruction(6 downto 4);
													state <= FETCH;
											end case;
										when '1'=>				--45.BCLR
											status<= "00000" & instruction(6 downto 4);
											state <= FETCH;
									end case;
								when '1'=>
									case instruction (7 downto 4) is
										when "0000"=>
											case instruction(0) is 
												when '0' =>		--46.RET
													state <= FETCH;
												when '1' =>		--47.ICALL
													state <= FETCH;
											end case;
										when "0001"=>
											case instruction(0) is 
												when '0' =>		--48.RETI
													state <= FETCH;
												when '1' =>		--49.EICALL
													state <= FETCH;
											end case;
										when "1000"=>			--50.SLEEP
											state <= FETCH;
										when "1001"=>			--51.BREAK
											state <= FETCH;
										when "1010"=>			--52.WDR
											state <= FETCH;
										when "1100"=>			--53.LPM Z
											state <= FETCH;
										when "1101"=>			--54.ELPM Z
											state <= FETCH;
										when "1110"=>			--55.SPM
											state <= FETCH;
										when others => null;
									end case;
								when others=>
									case instruction (3 downto 1) is
										when "000" =>
											case instruction(0) is
												when '0'=>		--56.COM
													VRd := instruction(8 downto 4);	
													Rd<=VRd;
													state <= FETCH;
												when '1'=>		--57.NEG
													VRd := instruction(8 downto 4);	
													Rd<=VRd;
													state <= FETCH;
											end case;
										when "001" => 
											case instruction(0) is
												when '0'=>		--58.SWAP
													VRd := instruction(8 downto 4);	
													Rd<=VRd;
													state <= FETCH;
												when '1'=>		--59.INC
													VRd := instruction(8 downto 4);	
													Rd<=VRd;
													state <= FETCH;
											end case;
										when "010" => 		--60.ASR
											VRd := instruction(8 downto 4);	
											Rd<=VRd;
											state <= FETCH;
										when "011" =>
											case instruction(0) is
												when '0'=>		--61.LSR
													VRd := instruction(8 downto 4);	
													Rd<=VRd;
													state <= FETCH;
												when '1'=>		--62.ROR
													VRd := instruction(8 downto 4);	
													Rd<=VRd;
													state <= FETCH;
											end case;
										when "101" => 		--63.DEC
											VRd := instruction(8 downto 4);	
											Rd<=VRd;
											state <= FETCH;
										when "110" => 		--64.JMP*
											imm <= "0000000000" & instruction(8 downto 4) & instruction(0);
											state <= FETCH;
										when "111" => 		--65.CALL*
											imm <= "0000000000" & instruction(8 downto 4) & instruction(0);
											state <= FETCH;
										when others => null;
									end case;
							end case;
						when "011"=>
							case instruction(8) is 
								when '0' =>			--66.ADIW
									imm <= "0000000000" & instruction(7 downto 6) & instruction(3 downto 0);
									VRd := "000" & instruction(5 downto 4);
									Rd<=VRd;
									state <= FETCH;
								when '1' =>			--67.SBIW
									imm <= "0000000000" & instruction(7 downto 6) & instruction(3 downto 0);
									VRd := "000" & instruction(5 downto 4);
									Rd<=VRd;
									state <= FETCH;
							end case;
						when "100"=>
							case instruction(8) is 
								when '0' =>			--68.CBI
									imm <= "00000000000" & instruction(7 downto 3);
									bits<= instruction(2 downto 0);
									state <= FETCH;
								when '1' =>			--69.SBIC
									imm <= "00000000000" & instruction(7 downto 3);
									bits<= instruction(2 downto 0);
									state <= FETCH;
							end case;
						when "101"=>
							case instruction(8) is 
								when '0' =>			--70.SBI
									imm <= "00000000000" & instruction(7 downto 3);
									bits<= instruction(2 downto 0);
									state <= FETCH;
								when '1' =>			--71.SBIS
									imm <= "00000000000" & instruction(7 downto 3);
									bits<= instruction(2 downto 0);
									state <= FETCH;
							end case;
						when others => null;		
					end case;
				case instruction(11 downto 10) is
					when "11"=>						--72.MUL
						VRd :=  instruction(8 downto 4); 
						VRr := instruction(9) & instruction(3 downto 0); 
						Rd<=VRd;
						Rr<=VRr;
						state <= FETCH;
					when others=> null;
				end case;
			when "1011"=>		--F11	
				case instruction(11) is 
					when '0' =>			--73.IN
						imm <= "0000000000" & instruction(10 downto 9) & instruction(3 downto 0);
						VRd :=  instruction(8 downto 4); 
						Rd<=VRd;
						state <= FETCH;
					when '1' =>			--74.OUT
						imm <= "0000000000" & instruction(10 downto 9) & instruction(3 downto 0);
						VRd :=  instruction(8 downto 4); 
						Rd<=VRd;
						state <= FETCH;
				end case;
			when "1100"=>		--F12	75.RJMP
				imm <= "0000" & instruction(11 downto 0);
				state <= FETCH;
			when "1101"=>		--F13	76.RCALL
				imm <= "0000" & instruction(11 downto 0);
				state <= FETCH;
			when "1110"=>		--F14	77.LDI
				imm <= "00000000" & instruction(11 downto 8) & instruction(3 downto 0);
				VRd :=  '0'& instruction(7 downto 4); 
				Rd<=VRd;
				state <= FETCH;
			when "1111"=>		--F15
				case instruction(11 downto 10) is
					when "00" =>
						case instruction (2 downto 0) is
							when "000"=>	--78.BRLO
								imm <= "000000000" & instruction(9 downto 3);
								state <= FETCH;
							when "001"=>	--79.BREQ
								imm <= "000000000" & instruction(9 downto 3);
								state <= FETCH;
							when "100"=>	--80.BRLT
								imm <= "000000000" & instruction(9 downto 3);
								state <= FETCH;
							When others=>	--81.BRBS
								imm <= "000000000" & instruction(9 downto 3);
								status <= "00000" & instruction(2 downto 0); 
								state <= FETCH;
						end case;
					when "01" =>
						case instruction (2 downto 0) is
							when "001"=>	--82.BRNE
								imm <= "000000000" & instruction(9 downto 3);
								state <= FETCH;
							when "100"=>	--83.BRGE
								imm <= "000000000" & instruction(9 downto 3);
								state <= FETCH;
							When others=>	--84.BRBC
								imm <= "000000000" & instruction(9 downto 3);
								status <= "00000" & instruction(2 downto 0); 
								state <= FETCH;
						end case;
					when "10" =>
						case instruction (9) is
							when '0'=>	--85.BLD
								VRd := instruction(8 downto 4);
								bits <= instruction(2 downto 0); 
								Rd<=VRd;
								state <= FETCH;
							when '1'=>	--86.BST
								VRd := instruction(8 downto 4);
								bits <= instruction(2 downto 0); 
								Rd<=VRd;
								state <= FETCH;
						end case;
					when "11" =>
						case instruction (9) is
							when '0'=>	--87.SBRC
								VRr := instruction(8 downto 4);
								bits <= instruction(2 downto 0); 
								Rr<=VRr;
								state <= FETCH;
							when '1'=>	--88.SBRS
								VRr := instruction(8 downto 4);
								bits <= instruction(2 downto 0); 
								Rr<=VRr;
								state <= FETCH;
						end case;
				end case;
			when others  => 
			--nop
      end case;
		b2:= instruction (15 downto 14) & instruction(12);
		case b2 is 
			when "100"=>
				case instruction(9) is
					when '0'=>
						case instruction(3) is 
							when '0'=>	--89.LDD Z
								VRd := instruction(8 downto 4);
								offset<= "00" & instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
								Rd<=VRd;
								state <= FETCH;
							when '1'=>	--90.LDD Y
								VRd := instruction(8 downto 4);
								offset<= "00" & instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
								Rd<=VRd;
								state <= FETCH;
						end case;
					when '1'=>
						case instruction(3) is 
							when '0'=>	--91.STD Z+q,Rr
								VRr := instruction(8 downto 4);
								offset<= "00" & instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
								Rr<=VRr;
								state <= FETCH;
							when '1'=>	--92.STD Y
								VRr := instruction(8 downto 4);
								offset<= "00" & instruction(2 downto 0) & instruction(11 downto 10) & instruction(13);
								Rr<=VRr;
								state <= FETCH;
						end case;
				end case;
			when others=>null;
		end case;
		end if;
    end if;
  end process;
 
end Behavioral;