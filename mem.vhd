library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem is
	generic (RamWidth : integer := 8;
				AddrWidth : integer := 10);
	port(
		clock : in std_logic;
		wr		: in std_logic;
		addr	: in std_logic_vector(AddrWidth-1 downto 0);
		dw		: in std_logic_vector(RamWidth-1 downto 0);
		dr		: out std_logic_vector(RamWidth-1 downto 0) );
end entity mem;

architecture MEMORY of mem is
	constant memSize : integer := 2**AddrWidth;
	type RAM is array(integer range <>) of std_logic_vector(RamWidth-1 downto 0);

	signal rmem : RAM(0 to MemSize-1);
	
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

end architecture MEMORY;
