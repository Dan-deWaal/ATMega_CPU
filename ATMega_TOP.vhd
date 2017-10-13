library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATMega_TOP is
	port( 
			RESET			: in  std_logic;
			CLK 			: in  std_logic );

end entity ATMega_TOP;

architecture ARCH_TOP of ATMega_TOP is
	
	signal RST : std_logic;
	signal C : std_logic;
	
begin

	make_cpu: entity work.CPU
	port map(
				RESET => RST,
				CLK => C);

	RST <= RESET;
--	top: process (CLK)
--	begin
--		if (rising_edge(CLK)) then
--			
--			RST <= RESET;
--		end if;
--	end process top;	

end architecture ARCH_TOP;
