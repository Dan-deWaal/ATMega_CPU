library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    port (
        CONTROL: in std_logic_vector(4 downto 0);
        X: in signed(15 downto 0);
        Y: in signed(7 downto 0);
        STATUS_IN: in std_logic_vector(7 downto 0);
        OUTPUT: out signed (15 downto 0);
        STATUS_OUT: out std_logic_vector(7 downto 0)
    );
end entity alu;

architecture alu_arch of alu is
    constant ADD_OP : std_logic_vector(4 downto 0) := "00001"; 
    constant ADD16_OP : std_logic_vector(4 downto 0) := "00010"; 
    constant SUB_OP : std_logic_vector(4 downto 0) := "00011"; 
    constant SUB16_OP : std_logic_vector(4 downto 0) := "00100"; 

    constant AND_OP : std_logic_vector(4 downto 0) := "00101"; 
    constant OR_OP : std_logic_vector(4 downto 0) := "00110"; 
    constant XOR_OP : std_logic_vector(4 downto 0) := "00111"; 
    constant NOT_OP : std_logic_vector(4 downto 0) := "01000"; 
    constant NEG_OP : std_logic_vector(4 downto 0) := "01001"; 

    constant MULU_OP : std_logic_vector(4 downto 0) := "01010"; 
    constant MULS_OP : std_logic_vector(4 downto 0) := "01011"; 
    constant MULSU_OP : std_logic_vector(4 downto 0) := "01100"; 
    constant FMULU_OP : std_logic_vector(4 downto 0) := "01101"; 
    constant FMULS_OP : std_logic_vector(4 downto 0) := "01110"; 
    constant FMULSU_OP : std_logic_vector(4 downto 0) := "01111"; 

    constant LSL_OP : std_logic_vector(4 downto 0) := "10000"; 
    constant LSR_OP : std_logic_vector(4 downto 0) := "10001"; 
    constant ASR_OP : std_logic_vector(4 downto 0) := "10010"; 
    constant ROTL_OP : std_logic_vector(4 downto 0) := "10011"; 
    constant ROTR_OP : std_logic_vector(4 downto 0) := "10100"; 

    signal carry_in : std_logic;

    signal add_result : signed(15 downto 0);
    signal mul_result : signed(15 downto 0);

    signal result : signed(15 downto 0);
	 signal x_copy : signed(15 downto 0);
    signal y_copy : signed (7 downto 0);
    signal negative : std_logic;
    signal overflow : std_logic;
begin
    x_copy(15 downto 8) <= X(15 downto 8) when CONTROL = ADD16_OP or CONTROL = SUB16_OP else
                      (others => X(7));

    x_copy(7 downto 0) <= (others => '0') when CONTROL = NEG_OP else
                     X(7 downto 0);

    y_copy <= not Y when CONTROL = SUB_OP or CONTROL = SUB16_OP else
              not X(7 downto 0) when CONTROL = NEG_OP else
              Y;

    carry_in <= '1' when CONTROL = SUB_OP or CONTROL = SUB16_OP or CONTROL = NEG_OP else
                '0';

    add_result <= x_copy + resize(y_copy, 16) + signed(to_stdlogicvector( '0' & carry_in));
    mul_result <= signed(unsigned(X(7 downto 0)) * unsigned(Y)) when CONTROL = MULU_OP or CONTROL = FMULU_OP else
                  X(7 downto 0) * Y when CONTROL = MULS_OP or CONTROL = FMULS_OP else
                  resize(X(7 downto 0) * signed( '0' & Y(7 downto 0)), 16) when CONTROL = MULSU_OP or CONTROL = FMULSU_OP else
                  (others => '-');

    with CONTROL(4 downto 0) select
        result <= add_result when ADD_OP,
                  add_result when ADD16_OP,
                  add_result when SUB_OP,
                  add_result when SUB16_OP,
                  "00000000" & (X(7 downto 0) and Y) when AND_OP,
                  "00000000" & (X(7 downto 0) or Y) when OR_OP,
                  "00000000" & (X(7 downto 0) xor Y) when XOR_OP,
                  "00000000" & (not X(7 downto 0)) when NOT_OP,
                  add_result when NEG_OP,
                  mul_result when MULU_OP,
                  mul_result when MULS_OP,
                  mul_result when MULSU_OP,
                  mul_result sll 1 when FMULU_OP,
                  mul_result sll 1 when FMULS_OP,
                  mul_result sll 1 when FMULSU_OP,
                  "00000000" & (X(7 downto 0) sll 1) when LSL_OP, 
                  "00000000" & (X(7 downto 0) srl 1) when LSR_OP,
                  "00000000" & shift_right(X(7 downto 0), 1) when ASR_OP,
                  "0000000" & (X(7 downto 0) rol 1) & STATUS_IN(0) when ROTL_OP, 
                  "00000000" & STATUS_IN(0) & (X(7 downto 1) ror 1) when ROTR_OP, 
                  (others => '0') when others;
	
--    result(0) <= STATUS_IN(0) when control = ROTL_OP 
--                 else result(0);
--	 result(7) <= STATUS_IN(0) when control = ROTR_OP
--                 else result(7);

    OUTPUT <= result;
	STATUS_OUT <= (others => '0');
end architecture alu_arch;