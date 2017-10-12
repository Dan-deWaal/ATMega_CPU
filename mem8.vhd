library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem8 is
	generic (AddrWidth : integer := 10 ); --1024 KB
	port(
		clock : in std_logic;
		wr		: in std_logic;
		addr	: in std_logic_vector(AddrWidth-1 downto 0);
		dw		: in std_logic_vector(7 downto 0);
		dr		: out std_logic_vector(7 downto 0) );
end entity mem8;

architecture MEMORY8 of mem8 is
	constant memSize : integer := 2**AddrWidth;
	type RAM is array(integer range <>) of std_logic_vector(7 downto 0);

	signal rmem : RAM(7 downto 0);
	
	begin
	process(clock) is
	begin
		if rising_edge(clock) then
			--read the memory location
			dr <= rmem(to_integer(unsigned(addr)));
			
			--write the memory location
			if wr = '1' then
				rmem(to_integer(unsigned(addr))) <= dw;
			end if;
			
		end if;	
	end process;

end architecture MEMORY8;
