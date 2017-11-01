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
         res(0) := "1110000100000010";
         res(1) := "1110000000010101";
         res(2) := "1001010000001110";
         res(3) := "0000000000000111";
         res(4) := "1110000000100011";
         res(5) := "1001010000001100";
         res(6) := "0000000000000000";
         res(7) := "1110000000111010";
         res(8) := "1001010100001000";

         for i in 9 to len-1 loop  -- change to 1 more than program length. **********
            res(i) := (others => '0');
         end loop;
			-- ***  PROG END HERE  ***
		
			return res;
	end function init_prog;
end package body prog_init;