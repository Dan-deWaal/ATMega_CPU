library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package prog_init is
	type mem_content is array(integer range <>) of std_logic_vector(15 downto 0);
	function init_prog(len:integer) return mem_content;
end package prog_init;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package body prog_init is
	function init_prog(len:integer) return mem_content is
		variable dlen : integer;
		variable	res : mem_content(0 to len-1);
		begin
		
			-- *** PROG START HERE ***
         res(0) := "1110000000001010";
         res(1) := "1111111100000010";
         res(2) := "1110000000010001";
         res(3) := "1110000000100001";

         for i in 4 to len-1 loop  -- change to 1 more than program length. **********
            res(i) := (others => '0');
         end loop;
			-- ***  PROG END HERE  ***
		
			return res;
	end function init_prog;
end package body prog_init;