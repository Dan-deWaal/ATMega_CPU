library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TestCPU is
end entity TestCPU;

architecture Test of TestCPU is
component CPU is
port(
	RESET	: in std_logic;
	CLK	: in std_logic
);
end component CPU;
	signal RST: std_logic := '0';
	signal CLK: std_logic := '0';
begin
DUT:CPU
port map(
	RESET => RST,
	CLK => CLK
);

process is
begin
	wait for 10 ns;
	CLK <= NOT CLK;
end process;

process is
begin
	wait for 1 ns;
	RST <= '1';
	wait for 5 ns;
	RST <= '0';
	wait;
end process;
end architecture Test;