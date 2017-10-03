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
	constant PROGMEM_SIZE : integer := 12; --4 kb
	constant DATAMEM_SIZE : integer := 16; --64 kb
	--constant gpreg_size : integer := 6; --32 bytes
	
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
	signal p_addr	: std_logic_vector(PROGMEM_SIZE-1 downto 0);
	signal p_dw		: std_logic_vector(15 downto 0);
	signal p_dr		: std_logic_vector(15 downto 0);
	
	signal d_wr		: std_logic;
	signal d_addr	: std_logic_vector(DATAMEM_SIZE-1 downto 0);
	signal d_dw		: std_logic_vector(7 downto 0);
	signal d_dr		: std_logic_vector(7 downto 0);
	
	--signal r_wr		: std_logic;
	--signal r_addr	: std_logic_vector(gpreg_size-1 downto 0);
	--signal r_dw		: std_logic_vector(7 downto 0);
	--signal r_dr		: std_logic_vector(7 downto 0);
	
	signal prog_counter : std_logic_vector(PROGMEM_SIZE-1 downto 0);
	type cpu_states is (FETCH, DECODE, EXECUTE, HALT);
	signal state: cpu_states := FETCH;
	
	signal i_decode : std_logic;
begin
	
	prog_mem : mem generic map (AddrWidth => PROGMEM_SIZE, RamWidth => 16) port map (clock, p_wr, p_addr, p_dw, p_dr);
	data_mem : mem generic map (AddrWidth => DATAMEM_SIZE) port map (clock, d_wr, d_addr, d_dw, d_dr);
	--gpreg : mem generic map (AddrWidth => gpreg_size) port map (clock, r_wr, r_addr, r_dw, r_dr);
	
	cpu_state_machine: process(CLK)
	begin
		if rising_edge(CLK) then
			case state is
				when FETCH => 
					state <= DECODE;
				when DECODE => 
					state <= EXECUTE;
				when EXECUTE => 
					state <= FETCH;
				when HALT => NULL;
			end case;
		end if;
	end process cpu_state_machine;
	
	i_decode <= '1' when state = DECODE else '0';

end architecture ATMEGA_CPU;