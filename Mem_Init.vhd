library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package mem_init is
	type mem_content is array(integer range <>) of std_logic_vector(15 downto 0);
	function init_prog(len:integer) return mem_content;
	constant program : mem_content := (X"0000", X"0000");
	--constant data_mem : mem_content := (X"00", X"00");

end package mem_init;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package body mem_init is
	function init_prog(len:integer) return mem_content is
	variable dlen : integer;
	variable	res : mem_content(0 to len-1);
	variable data : mem_content;
	begin
	
--		if wid = 8 then
--			data := data_mem;
--		if wid = 16 then
--			data := program;
--		else
--			assert 1 = 0 report "whacky memory size" severity ERROR;
--		end if;
		data := program;
		
		dlen := data'length;
		
		assert dlen <= len report "memory too small for initilization" severity ERROR;
		
		for i in 0 to dlen-1 loop
			res(i) := data(i);
		end loop;
		
		for i in dlen to len-1 loop
			res(i) := (others => '0');
		end loop;
		
	end function init_prog;

end package body mem_init;