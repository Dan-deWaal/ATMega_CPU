library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity execute is
    Port ( 	clock : in  STD_LOGIC;
			I_en : in  STD_LOGIC;
			Rd : out  STD_LOGIC_VECTOR (4 downto 0);
			Rr : out  STD_LOGIC_VECTOR (4 downto 0);
			Offset : out  STD_LOGIC_VECTOR (7 downto 0);
			imm : out  STD_LOGIC_VECTOR (15 downto 0);
			pre_dec: out std_LOGIC;
			post_dec: out std_LOGIC;
			status  : out std_LOGIC_VECTOR(7 downto 0);
			bits: out std_LOGIC_VECTOR(2 downto 0);
			opcode : out  STD_LOGIC_VECTOR (7 downto 0) );
end execute;
 
architecture behaviour of execute is
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if I_en = '1' then
				case opcode is
					when 1 =>
						NULL;
					when others =>
						NULL;
				end case;
			end if;
		end if;
	end process;
end behaviour;