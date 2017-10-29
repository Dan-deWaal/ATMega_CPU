library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package prog_init is
	type mem_content is array(integer range <>) of std_logic_vector(15 downto 0);
	function init_prog(len:integer) return mem_content;
	--constant program : mem_content := (x"9408", x"9418", x"9428", x"9438", x"9448", x"9458", x"9468", x"9478");
	constant program : mem_content := ("1001010000011000", "1001010000011000"); --, x"9418", x"9428", x"9438", x"9448", x"9458", x"9468", x"9478");
	--constant data_mem : mem_content := (X"00", X"00");

end package prog_init;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package body prog_init is
	function init_prog(len:integer) return mem_content is
		variable dlen : integer;
		variable	res : mem_content(0 to len-1);
		--variable data : mem_content;
		begin
		
	--		if wid = 8 then
	--			data := data_mem;
	--		if wid = 16 then
	--			data := program;
	--		else
	--			assert 1 = 0 report "whacky memory size" severity ERROR;
	--		end if;
			--data := program;
			
			dlen := program'length;
			
			assert dlen <= len report "memory too small for initilization" severity ERROR;
			
--			for i in 0 to dlen-1 loop
--				res(i) := program(i);
--			end loop;
			res(0) := "1110011000010100";
			res(1) := "1001001100010000";
			res(2) := "0000111100000001";
--			res(2) := "0000000000000001";
--			res(3) := "1001000100100000";
--			res(4) := "0000000000000001";
			
			for i in 3 to len-1 loop  -- change to 1 more than program length. **********
				res(i) := (others => '0');
			end loop;
		
			return res;
	end function init_prog;

end package body prog_init;