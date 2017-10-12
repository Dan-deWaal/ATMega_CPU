library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.prog_init.all;

entity mem16 is
	generic (AddrWidth : integer := 10 ); --1024 KB
	port(
		clock : in std_logic;
		addr	: in std_logic_vector(AddrWidth-1 downto 0);
		dr		: out std_logic_vector(15 downto 0) );
end entity mem16;

architecture MEMORY16 of mem16 is
	constant memSize : integer := 2**AddrWidth;
	--type RAM is array(integer range <>) of std_logic_vector(RamWidth-1 downto 0);

	signal rmem : mem_content(0 to MemSize-1) := init_prog(memSize);
	
	begin
	process(clock) is
	begin
		if rising_edge(clock) then
		
			--read the memory location
			dr <= rmem(to_integer(unsigned(addr)));
			
		end if;	
	end process;

end architecture MEMORY16;
