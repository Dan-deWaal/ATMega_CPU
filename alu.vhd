library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
	port (
		CONTROL: in std_logic_vector(7 downto 0);
		X: in signed(15 downto 0);
		Y: in signed(7 downto 0);
		OUTPUT: out signed (15 downto 0);
		STATUS: out std_logic_vector(8 downto 0)
	);
end entity alu;

architecture alu_arch of alu is
	signal sum : signed(15 downto 0);
	signal sub : signed(15 downto 0);
	signal negative : std_logic;
	signal overflow : std_logic;
begin
	-- opcode ADD == 000001
	-- opcode 16 bit ADD == 000010
	sum <= X + ("00000000" & Y);
	-- opcode SUB == 000011
	-- opcode 16 bit SUB == 000100
	sub <= X - ("00000000" & Y);

	with CONTROL(5 downto 0) select
		STATUS(0) <= (X(7) and Y(7)) or (Y(7) and not sum(7)) or (not sum(7) and X(7)) when "000001",
					 not sum(15) and X(15) when "000010",
					 (not X(7) and Y(7)) or (Y(7) and sum(7)) or (sum(7) and not X(7)) when "000011",
					 sum(15) and not X(15) when "000100",
					 '-' when others;

	with CONTROL(5 downto 0) select
		STATUS(1) <= not sum(7) and not sum(6) and not sum(5) and not sum(4) and not sum(3) and not sum(2) and not sum(1) and not sum(0) when "000001",
					 not sum(15) and not sum(14) and not sum(13) and not sum(12) and not sum(11) and not sum(10) and not sum(9) and not sum(8) and not sum(7) and not sum(6) and not sum(5) and not sum(4) and not sum(3) and not sum(2) and not sum(1) and not sum(0) when "000010",
					 not sum(7) and not sum(6) and not sum(5) and not sum(4) and not sum(3) and not sum(2) and not sum(1) and not sum(0) when "000011",
					 not sum(15) and not sum(14) and not sum(13) and not sum(12) and not sum(11) and not sum(10) and not sum(9) and not sum(8) and not sum(7) and not sum(6) and not sum(5) and not sum(4) and not sum(3) and not sum(2) and not sum(1) and not sum(0) when "000100",
					 '-' when others;

	with CONTROL(5 downto 0) select
		negative <= sum(7) when "000001",
					sum(15) when "000010",
					sum(7) when "000011",
					sum(15) when "000100",
					'-' when others;
	STATUS(2) <= negative;

	with CONTROL(5 downto 0) select
		overflow <= (X(7) and Y(7) and not sum(7)) or (not X(7) and not Y(7) and sum(7)) when "000001",
					sum(15) and not X(15) when "000010",
					(X(7) and not Y(7) and not sum(7)) or (not X(7) and Y(7) and sum(7)) when "000011",
					sum(15) and not X(15) when "000100",
					'-' when others;
	STATUS(3) <= overflow;

	with CONTROL(5 downto 0) select
		STATUS(4) <= negative xor overflow when "000001",
					 negative xor overflow when "000010",
					 negative xor overflow when "000011",
					 negative xor overflow when "000100",
					 '-' when others;

	with CONTROL(5 downto 0) select
		STATUS(5) <= (X(3) and Y(3)) or (Y(3) and not sum(3)) or (not sum(3) and X(3)) when "000001",
					 (not X(3) and Y(3)) or (Y(3) and sum(3)) or (sum(3) and not X(3)) when "000011",
					 '-' when others;

	with CONTROL(5 downto 0) select
		OUTPUT <= resize(sum, 16) when "000001",
				  sum when "000010",
				  resize(sub, 16) when "000011",
				  sub when "000100",
				  (others => '0') when others;

end architecture alu_arch;