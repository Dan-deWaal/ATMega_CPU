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
    constant ADD_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(0, 5));
    constant ADC_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(1, 5));
    constant ADIW_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(16, 5));
    constant INC_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(2, 5));

    constant SUB_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(3, 5));
    constant SBC_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(4, 5));
    constant SBIW_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(17, 5));
    constant DEC_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(5, 5));
    constant NEG_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(6, 5));

    constant AND_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(7, 5));
    constant OR_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(8, 5));
    constant XOR_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(9, 5));
    constant NOT_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(10, 5));

    constant MULU_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(24, 5));
    constant MULS_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(25, 5));
    constant MULSU_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(26, 5));
    constant FMULU_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(27, 5));
    constant FMULS_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(28, 5));
    constant FMULSU_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(29, 5));

    constant LSL_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(11, 5));
    constant LSR_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(12, 5));
    constant ASR_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(13, 5));
    constant ROL_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(14, 5));
    constant ROR_OP : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(15, 5));

    signal add_result : signed(15 downto 0);
    signal sub_result : signed(15 downto 0);
    signal mul_result : signed(15 downto 0);

    signal result : signed(15 downto 0);
    signal carry : std_logic;
    signal negative : std_logic;
    signal overflow : std_logic;
begin
    add_result <= "0000000" & ('0' & X(7 downto 0)) + ('0' & Y) + ('0' & STATUS_IN(0)) when CONTROL = ADC_OP else
                  "0000000" & ('0' & X(7 downto 0)) + ('0' & Y) when CONTROL = ADD_OP else
						"0000000" & ('0' & X(7 downto 0)) + 1 when CONTROL = INC_OP else
                  X + Y;

    sub_result <= "0000000" & ('0' & X(7 downto 0)) - ('0' & Y) - ('0' & STATUS_IN(0)) when CONTROL = SBC_OP else
                  "0000000" & ('0' & X(7 downto 0)) - ('0' & Y) when CONTROL = SUB_OP else
                  X - 1 when CONTROL = DEC_OP else
                  0 - X when CONTROL = NEG_OP else
                  X - Y;

    mul_result <= signed(unsigned(X(7 downto 0)) * unsigned(Y)) when CONTROL = MULU_OP or CONTROL = FMULU_OP else
                  X(7 downto 0) * Y when CONTROL = MULS_OP or CONTROL = FMULS_OP else
                  resize(X(7 downto 0) * signed( '0' & Y(7 downto 0)), 16) when CONTROL = MULSU_OP or CONTROL = FMULSU_OP else
                  (others => '-');

    with control(4 downto 0) select
        result <= "00000000" & add_result(7 downto 0) when ADD_OP,
                  "00000000" & add_result(7 downto 0) when ADC_OP,
                  add_result when ADIW_OP,
                  "00000000" & add_result(7 downto 0) when INC_OP,
                  
                  "00000000" & sub_result(7 downto 0) when SUB_OP,
                  "00000000" & sub_result(7 downto 0) when SBC_OP,
                  sub_result when SBIW_OP,
                  "00000000" & sub_result(7 downto 0) when DEC_OP,
                  "00000000" & sub_result(7 downto 0) when NEG_OP,
                  
                  "00000000" & (X(7 downto 0) and Y) when AND_OP,
                  "00000000" & (X(7 downto 0) or Y) when OR_OP,
                  "00000000" & (X(7 downto 0) xor Y) when XOR_OP,
                  "00000000" & not X(7 downto 0) when NOT_OP,

                  mul_result when MULU_OP,
                  mul_result when MULS_OP,
                  mul_result when MULSU_OP,
                  mul_result(14 downto 0) & '0' when FMULU_OP,
                  mul_result(14 downto 0) & '0' when FMULS_OP,
                  mul_result(14 downto 0) & '0' when FMULSU_OP,
                  
                  "00000000" & X(7 downto 1) & '0' when LSL_OP, 
                  "000000000" & X(6 downto 0) when LSR_OP,
                  "00000000" & X(7) & X(7 downto 1) when ASR_OP,
                  "00000000" & X(6 downto 0) & STATUS_IN(0) when ROL_OP, 
                  "00000000" & STATUS_IN(0) & X(7 downto 1) when ROR_OP, 
                  (others => '0') when others;

    with control(4 downto 0) select
        carry <= add_result(8) when ADD_OP,
                 add_result(8) when ADC_OP,
                 (not add_result(15)) and X(15) when ADIW_OP,
                 STATUS_IN(0) when INC_OP,

                 sub_result(8) when SUB_OP,
                 sub_result(8) when SBC_OP,
                 sub_result(15) and (not X(15)) when SBIW_OP,
                 STATUS_IN(0) when DEC_OP,
                 sub_result(8) when NEG_OP,
                 
                 STATUS_IN(0) when AND_OP,
                 STATUS_IN(0) when OR_OP,
                 STATUS_IN(0) when XOR_OP,
                 '1' when NOT_OP,

                 mul_result(15) when MULU_OP,
                 mul_result(15) when MULS_OP,
                 mul_result(15) when MULSU_OP,
                 mul_result(15) when FMULU_OP,
                 mul_result(15) when FMULS_OP,
                 mul_result(15) when FMULSU_OP,

                 X(7) when LSL_OP,
                 X(0) when LSR_OP,
                 X(0) when ASR_OP,
                 X(7) when ROL_OP,
                 X(0) when ROR_OP,
                 '0' when others;
    STATUS_OUT(0) <= carry;

    STATUS_OUT(1) <= '1' when result = 0 else '0';

    with control(4 downto 3) select
        negative <= result(15) when "10",
                    STATUS_IN(2) when "11",
                    result(7) when others;
    STATUS_OUT(2) <= negative;

    with control(4 downto 0) select
        overflow <= (X(7) and Y(7) and not add_result(7)) or 
                        (not X(7) and not Y(7) and add_result(7)) when ADD_OP,
                    (X(7) and Y(7) and not add_result(7)) or 
                        (not X(7) and not Y(7) and add_result(7)) when ADC_OP,
                    add_result(15) and (not X(15)) when ADIW_OP,
                    not X(7) and X(6) and X(5) and X(4) and X(3) and X(2) and X(1) and X(0) when INC_OP,

                    (X(7) and not Y(7) and not sub_result(7)) or 
                        (not X(7) and Y(7) and sub_result(7)) when SUB_OP,
                    (X(7) and not Y(7) and not sub_result(7)) or 
                        (not X(7) and Y(7) and sub_result(7)) when SBC_OP,
                    sub_result(15) and (not X(15)) when SBIW_OP,
                    X(7) and not X(6) and not X(5) and not X(4) and not X(3) and not X(2) and not X(1) and not X(0) when DEC_OP,
                    X(7) and not X(6) and not X(5) and not X(4) and not X(3) and not X(2) and not X(1) and not X(0) when NEG_OP,
                    
                    '0' when AND_OP,
                    '0' when OR_OP,
                    '0' when XOR_OP,
                    '0' when NOT_OP,

                    STATUS_IN(3) when MULU_OP,
                    STATUS_IN(3) when MULS_OP,
                    STATUS_IN(3) when MULSU_OP,
                    STATUS_IN(3) when FMULU_OP,
                    STATUS_IN(3) when FMULS_OP,
                    STATUS_IN(3) when FMULSU_OP,

                    negative xor carry when LSL_OP,
                    negative xor carry when LSR_OP,
                    negative xor carry when ASR_OP,
                    negative xor carry when ROL_OP,
                    negative xor carry when ROR_OP,
                    '0' when others;
    STATUS_OUT(3) <= overflow;

    STATUS_OUT(4) <= STATUS_IN(4) when control(4 downto 3) = "11" else
                 negative xor overflow;

    with control(4 downto 0) select
        STATUS_OUT(5) <= (X(3) and Y(3)) or (Y(3) and not add_result(3)) or 
                            (not add_result(3) and X(3)) when ADD_OP,
                         (X(3) and Y(3)) or (Y(3) and not add_result(3)) or 
                            (not add_result(3) and X(3)) when ADC_OP,
                         STATUS_IN(5) when ADIW_OP,
                         STATUS_IN(5) when INC_OP,

                         (not X(3) and Y(3)) or (Y(3) and sub_result(3)) or
                            (add_result(3) and not X(3)) when SUB_OP,
                         (not X(3) and Y(3)) or (Y(3) and sub_result(3)) or
                            (add_result(3) and not X(3)) when SBC_OP,
                         STATUS_IN(5) when SBIW_OP,
                         STATUS_IN(5) when DEC_OP,
                         (not X(3) and Y(3)) or (Y(3) and sub_result(3)) or
                            (add_result(3) and not X(3)) when NEG_OP,
                     
                         STATUS_IN(5) when AND_OP,
                         STATUS_IN(5) when OR_OP,
                         STATUS_IN(5) when XOR_OP,
                         STATUS_IN(5) when NOT_OP,

                         STATUS_IN(5) when MULU_OP,
                         STATUS_IN(5) when MULS_OP,
                         STATUS_IN(5) when MULSU_OP,
                         STATUS_IN(5) when FMULU_OP,
                         STATUS_IN(5) when FMULS_OP,
                         STATUS_IN(5) when FMULSU_OP,

                         X(3) when LSL_OP,
                         STATUS_IN(5) when LSR_OP,
                         STATUS_IN(5) when ASR_OP,
                         X(3) when ROL_OP,
                         STATUS_IN(5) when ROR_OP,
                         '0' when others;

    OUTPUT <= result;
    STATUS_OUT(7 downto 6) <= STATUS_IN(7 downto 6);
end architecture alu_arch;