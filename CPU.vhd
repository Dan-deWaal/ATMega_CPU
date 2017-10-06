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

	component decode
		port(
			clock : in  STD_LOGIC;
			I_dataInst : in  STD_LOGIC_VECTOR (15 downto 0);
			I_en : in  STD_LOGIC;
			Rd : out  STD_LOGIC_VECTOR (4 downto 0);
			Rr : out  STD_LOGIC_VECTOR (4 downto 0);
			Offset : out  STD_LOGIC_VECTOR (7 downto 0);
			imm : out  STD_LOGIC_VECTOR (15 downto 0);
			pre_dec: out std_LOGIC;
			post_dec: out std_LOGIC;
			status  : out std_LOGIC_VECTOR(7 downto 0);
			bits: out std_LOGIC_VECTOR(2 downto 0);
			opcode : out  STD_LOGIC_VECTOR (7 downto 0) );
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
		
	type reg is array (0 to 31) of std_logic_vector(7 downto 0);
	signal registers	: reg;
	signal instruction: std_logic_vector(15 downto 0);
	signal Rd			: std_logic_vector(4 downto 0);
	signal Rr			: std_logic_vector(4 downto 0);
	signal offset		: std_logic_vector(7 downto 0);
	signal imm			: std_logic_vector(15 downto 0);
	signal pre_dec		: std_logic;
	signal post_dec	: std_logic;
	signal status		: std_logic_vector(7 downto 0);
	signal bits			: std_logic_vector(2 downto 0);
	signal opcode		: std_logic_vector(7 downto 0);
	signal alucontrol : std_logic_vector(4 downto 0);
	
	signal prog_counter : std_logic_vector(PROGMEM_SIZE-1 downto 0);
	type cpu_states is (FETCHSTATE, DECODESTATE, EXECUTESTATE, HALTSTATE);
	signal state: cpu_states := FETCHSTATE;
	
	signal i_decode : std_logic;
begin
	-- Create components
	prog_mem : mem generic map (AddrWidth => PROGMEM_SIZE, RamWidth => 16) port map (clock, p_wr, p_addr, p_dw, p_dr);
	data_mem : mem generic map (AddrWidth => DATAMEM_SIZE) port map (clock, d_wr, d_addr, d_dw, d_dr);
	decoder : decode port map (clock, p_dr, i_decode, Rd, Rr, offset, imm, pre_dec, post_dec, status, bits, opcode);
	
	cpu_state_machine: process(CLK)
	begin
		if rising_edge(CLK) then
			case state is
				when FETCHSTATE => 
					state <= DECODESTATE;
				when DECODESTATE => 
					state <= EXECUTESTATE;
				when EXECUTESTATE => 
					state <= FETCHSTATE;
				when HALTSTATE => 
					NULL;
			end case;
		end if;
	end process cpu_state_machine;
	
	cpu_run: process(state, CLK)
	begin
	if rising_edge(CLK) then
		case state is
				when FETCHSTATE => 
					--new instruction is available at p_dr at the end of this clock cycle.
					NULL;
				when DECODESTATE => 
					
				when EXECUTESTATE => 
				
				when HALTSTATE => 
					NULL;
			end case;
	end if;
	end process fetch;
	
	i_decode <= '1' when state = DECODESTATE else '0';

end architecture ATMEGA_CPU;