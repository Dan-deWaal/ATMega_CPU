library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity execute is
    Port ( clock 	: in  std_logic;
			I_en 		: in  std_logic;
			Rd 		: in  std_logic_vector(4 downto 0);
			Rr 		: in  std_logic_vector(4 downto 0);
			Offset 	: in  std_logic_vector(7 downto 0);
			imm 		: in  std_logic_vector(15 downto 0);
			pre_dec	: in 	std_logic;
			post_dec	: in 	std_logic;
			status  	: in 	std_logic_vector(7 downto 0);
			bits		: in 	std_logic_vector(2 downto 0);
			opcode 	: in  std_logic_vector(7 downto 0)
			regdata 	: out std_logic_vector(7 downto 0) 
			p_addr	: out std_logic_vector( ) );
end execute;
 
architecture behaviour of execute is
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if I_en = '1' then
				case opcode is
					when "00000001" =>
						NULL;
					when others =>
						NULL;
				end case;
			end if;
		end if;
	end process;
end behaviour;