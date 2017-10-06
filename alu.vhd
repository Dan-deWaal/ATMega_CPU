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

    signal result : signed(15 downto 0);
    signal y_copy : signed (7 downto 0);
    signal negative : std_logic;
    signal overflow : std_logic;
begin
    X(15 downto 8) <= X(15 downto 8) when CONTROL = ADD16_OP or CONTROL = SUB16_OP else
                      (others <= '0');

    X(7 downto 0) <= (others <= '0') when CONTROL = NEG_OP else;
                     X(7 downto 0);

    y_copy <= not Y when CONTROL = SUB_OP or CONTROL = SUB16_OP else
              not X when CONTROL = NEG_OP else
              Y;

    carry_in <= '1' when CONTROL = SUB_OP or CONTROL = SUB16_OP or CONTROL = NEG_OP else
                '0';

    with CONTROL(4 downto 0) select
        result(7 downto 0) <= X + ("00000000" & y_copy) + signed("0" & carry_in, 16) when ADD_OP,
                  X + ("00000000" & y_copy) + signed("0" & carry_in, 16) when ADD16_OP,
                  X + ("00000000" & y_copy) + signed("0" & carry_in, 16) when SUB_OP,
                  X + ("00000000" & y_copy) + signed("0" & carry_in, 16) when SUB16_OP,
                  "00000000" & (X(7 downto 0) and Y) when AND_OP,
                  "00000000" & (X(7 downto 0) or Y) when OR_OP,
                  "00000000" & (X(7 downto 0) xor Y) when XOR_OP,
                  "00000000" & (not X(7 downto 0)) when NOT_OP,
                  X + ("00000000" & y_copy) + signed("0" & carry_in, 16) when NEG_OP,
                  unsigned(X(7 downto 0), 8) * unsigned(Y, 8) when MULU_OP,
                  X(7 downto 0) * Y, 8 when MULS_OP,
                  X(7 downto 0) * Y, 8 when MULS_OP,

end architecture alu_arch;