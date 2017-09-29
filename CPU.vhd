library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port(
		PORT_A : std_logic_vector(7 downto 0);
		CLK	 :	std_logic
	);
end entity CPU;

architecture ATMEGA_CPU of CPU is
	constant progmem_size : integer := 12; --4 kb
	constant datamem_size : integer := 16; --64 kb
	constant gpreg_size : integer := 6; --32 bytes
	
	component mem
		generic (RamWidth : integer := 8;
					AddrWidth : integer := 10);
		port(
			clock : in std_logic;
			wr		: in std_logic;
			addr	: in std_logic_vector(AddrWidth-1 downto 0);
			dw		: in std_logic_vector(RamWidth-1 downto 0);
			dr		: out std_logic_vector(RamWidth-1 downto 0) );
	end component;					
	
	signal PA_IO 	: std_logic_vector(7 downto 0);
	
	signal clock	: std_logic;
	
	signal p_wr		: std_logic;
	signal p_addr	: std_logic_vector(progmem_size-1 downto 0);
	signal p_dw		: std_logic_vector(15 downto 0);
	signal p_dr		: std_logic_vector(15 downto 0);
	
	signal d_wr		: std_logic;
	signal d_addr	: std_logic_vector(datamem_size-1 downto 0);
	signal d_dw		: std_logic_vector(7 downto 0);
	signal d_dr		: std_logic_vector(7 downto 0);
	
	signal r_wr		: std_logic;
	signal r_addr	: std_logic_vector(gpreg_size-1 downto 0);
	signal r_dw		: std_logic_vector(7 downto 0);
	signal r_dr		: std_logic_vector(7 downto 0);
	
begin
	
	prog_mem : mem generic map (AddrWidth => progmem_size, RamWidth => 16) port map (clock, p_wr, p_addr, p_dw, p_dr);
	data_mem : mem generic map (AddrWidth => datamem_size) port map (clock, d_wr, d_addr, d_dw, d_dr);
	gpreg : mem generic map (AddrWidth => gpreg_size) port map (clock, r_wr, r_addr, r_dw, r_dr);
	
	run_cpu: process(CLK)
	begin
		clock <= CLK;
	end process run_cpu;
	

end architecture ATMEGA_CPU;