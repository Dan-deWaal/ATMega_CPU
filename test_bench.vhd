library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_bench is
end entity test_bench;

architecture test of test_bench is
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

    signal CONTROL: std_logic_vector(4 downto 0);
    signal X: signed(15 downto 0);
    signal Y: signed(7 downto 0);
    signal OUTPUT: signed (15 downto 0);
    signal STATUS_OUT: std_logic_vector(7 downto 0);
    signal STATUS_IN: std_logic_vector(7 downto 0);

begin
    process begin

    STATUS_IN <= "00000000";

    ------------------------------------ ADDITION : ADD ----------------------------------------------
    X <= to_signed(20, 16);
    Y <= to_signed(10, 8);
    CONTROL <= ADD_OP;
    wait for 1 us;
    assert OUTPUT = 30 report "Incorrect ADD calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADD_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ADD calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADD_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect ADD calculation" severity error;

    -- Overflow
    X <= to_signed(200, 16);
    Y <= to_signed(200, 8);
    CONTROL <= ADD_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 144 report "Incorrect ADD calculation" severity error;

    -- Carry
    X <= to_signed(-1, 16);
    Y <= to_signed(2, 8);
    CONTROL <= ADD_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 1 report "Incorrect ADD calculation" severity error;

    ------------------------------ ADDITION : ADD16 ------------------------------------- 
    X <= to_signed(1600, 16);
    Y <= to_signed(100, 8);
    CONTROL <= ADIW_OP;
    wait for 1 us;
    assert OUTPUT = 1700 report "Incorrect ADD16 calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADIW_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ADD16_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADIW_OP;
    wait for 1 us;
    assert OUTPUT = -25 report "Incorrect ADD16_OP calculation" severity error;

    -- Overflow
    X <= to_signed(32765, 16);
    Y <= to_signed(3, 8);
    CONTROL <= ADIW_OP;
    wait for 1 us;
    assert OUTPUT = 30 report "Incorrect ADD16_OP calculation" severity error;

    -- Carry
    X <= to_signed(-1, 16);
    Y <= to_signed(2, 8);
    CONTROL <= ADIW_OP;
    wait for 1 us;
    assert OUTPUT = 30 report "Incorrect ADD16_OP calculation" severity error;


    ------------------------------ ADDITION : ADC ------------------------------------- 
    STATUS_IN <= "00000001";
    X <= to_signed(20, 16);
    Y <= to_signed(10, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT = 31 report "Incorrect ADD calculation" severity error;

    -- Zero Test
    X <= to_signed(-1, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ADD calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -49 report "Incorrect ADD calculation" severity error;

    -- Overflow
    X <= to_signed(200, 16);
    Y <= to_signed(200, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 145 report "Incorrect ADD calculation" severity error;

    -- Carry
    X <= to_signed(-1, 16);
    Y <= to_signed(2, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 2 report "Incorrect ADD calculation" severity error;

    STATUS_IN <= "00000000";
    X <= to_signed(20, 16);
    Y <= to_signed(10, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT = 30 report "Incorrect ADD calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ADD calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect ADD calculation" severity error;

    -- Overflow
    X <= to_signed(200, 16);
    Y <= to_signed(200, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 144 report "Incorrect ADD calculation" severity error;

    -- Carry
    X <= to_signed(-1, 16);
    Y <= to_signed(2, 8);
    CONTROL <= ADC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 1 report "Incorrect ADD calculation" severity error;

    ------------------------------------ ADDITION : INCREMENT ----------------------------------------------
    Y <= to_signed(0, 8);

    X <= to_signed(29, 16);
    CONTROL <= INC_OP;
    wait for 1 us;
    assert OUTPUT = 30 report "Incorrect ADD calculation" severity error;

    -- Zero Test
    X <= to_signed(-1, 16);
    CONTROL <= INC_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ADD calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-51, 16);
    CONTROL <= INC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect ADD calculation" severity error;

    -- Overflow
    X <= to_signed(127, 16);
    CONTROL <= INC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 144 report "Incorrect ADD calculation" severity error;

    -- Carry
    STATUS_IN <= "00000001";
    X <= to_signed(-1, 16);
    CONTROL <= INC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = 1 report "Incorrect ADD calculation" severity error;

    -------------------------------------  ADDITION : SUB ------------------------------------- 
    STATUS_IN <= "00000000";
    X <= to_signed(20, 16);
    Y <= to_signed(10, 8);
    CONTROL <= SUB_OP;
    wait for 1 us;
    assert OUTPUT = 10 report "Incorrect SUB calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= SUB_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect SUB_OP calculation" severity error;

    -- Negative Test, Sign Test and Carry bit
    X <= to_signed(0, 16);
    Y <= to_signed(50, 8);
    CONTROL <= SUB_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect SUB_OP calculation" severity error;

    -- Overflow
    X <= to_signed(-127, 16);
    Y <= to_signed(100, 8);
    CONTROL <= SUB_OP;
    wait for 1 us;
    assert OUTPUT = 6 report "Incorrect SUB_OP calculation" severity error;

    ------------------------------------- ADDITION : SUB16 ------------------------------------- 
    X <= to_signed(1600, 16);
    Y <= to_signed(100, 8);
    CONTROL <= SBIW_OP;
    wait for 1 us;
    assert OUTPUT = 1500 report "Incorrect SUB16 calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= SBIW_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect SUB16_OP calculation" severity error;

    -- Negative Test and Carry Test
    X <= to_signed(0, 16);
    Y <= to_signed(50, 8);
    CONTROL <= SBIW_OP;
    wait for 1 us;
    assert OUTPUT = -25 report "Incorrect SUB16_OP calculation" severity error;

    -- Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= SBIW_OP;
    wait for 1 us;
    assert OUTPUT = -25 report "Incorrect SUB16_OP calculation" severity error;

    -- Overflow
    X <= to_signed(-32700, 16);
    Y <= to_signed(5000, 8);
    CONTROL <= SBIW_OP;
    wait for 1 us;
    assert OUTPUT = 30 report "Incorrect SUB16_OP calculation" severity error;

    ------------------------------------- ADDITION : SBC_OP ------------------------------------- 

    STATUS_IN <= "00000001";

    X <= to_signed(21, 16);
    Y <= to_signed(10, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT = 10 report "Incorrect SBC_OP calculation" severity error;

    -- Zero Test
    X <= to_signed(1, 16);
    Y <= to_signed(0, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect SBC_OP calculation" severity error;

    -- Negative Test, Sign Test and Carry bit
    X <= to_signed(1, 16);
    Y <= to_signed(50, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect SBC_OP calculation" severity error;

    -- Overflow
    X <= to_signed(-126, 16);
    Y <= to_signed(100, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT = 6 report "Incorrect SBC_OP calculation" severity error;

    STATUS_IN <= "00000000";

    X <= to_signed(20, 16);
    Y <= to_signed(10, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT = 10 report "Incorrect SBC_OP calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect SBC_OP calculation" severity error;

    -- Negative Test, Sign Test and Carry bit
    X <= to_signed(0, 16);
    Y <= to_signed(50, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect SBC_OP calculation" severity error;

    -- Overflow
    X <= to_signed(-127, 16);
    Y <= to_signed(100, 8);
    CONTROL <= SBC_OP;
    wait for 1 us;
    assert OUTPUT = 6 report "Incorrect SBC_OP calculation" severity error;


    -------------------------------------  ADDITION : SUB DECREMENT ------------------------------------- 
    STATUS_IN <= "00000000";
    Y <= to_signed(0, 8);
    X <= to_signed(20, 16);
    CONTROL <= DEC_OP;
    wait for 1 us;
    assert OUTPUT = 19 report "Incorrect DEC_OP calculation" severity error;

    -- Zero Test
    X <= to_signed(1, 16);
    CONTROL <= DEC_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect DEC_OP calculation" severity error;

    -- Negative Test, Sign Test and Carry bit
    X <= to_signed(-50, 16);
    CONTROL <= DEC_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect DEC_OP calculation" severity error;

    -- Overflow
    X <= to_signed(-127, 16);
    CONTROL <= DEC_OP;
    wait for 1 us;
    assert OUTPUT = 6 report "Incorrect DEC_OP calculation" severity error;


    ------------------------------------ LOGIC : AND ------------------------------------- 
    X <= to_signed(65, 16);
    Y <= to_signed(33, 8);
    CONTROL <= AND_OP;
    wait for 1 us;
    assert OUTPUT = 1 report "Incorrect AND calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= AND_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect AND_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(-50, 8);
    CONTROL <= AND_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect AND_OP calculation" severity error;

    ------------------------------------ LOGIC : OR ------------------------------------- 
    X <= to_signed(65, 16);
    Y <= to_signed(33, 8);
    CONTROL <= OR_OP;
    wait for 1 us;
    assert OUTPUT = 97 report "Incorrect OR calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= OR_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect OR_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= OR_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect OR_OP calculation" severity error;

    ------------------------------------ LOGIC : XOR ------------------------------------- 
    X <= to_signed(65, 16);
    Y <= to_signed(33, 8);
    CONTROL <= XOR_OP;
    wait for 1 us;
    assert OUTPUT = 96 report "Incorrect XOR calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= XOR_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect XOR_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= XOR_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect XOR_OP calculation" severity error;

    ------------------------------------ LOGIC : NOT ------------------------------------- 
    X <= to_signed(65, 16);
    Y <= to_signed(0, 8);
    CONTROL <= NOT_OP;
    wait for 1 us;
    assert OUTPUT = 190 report "Incorrect NOT calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= NOT_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect NOT_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(1, 16);
    Y <= to_signed(254, 8);
    CONTROL <= NOT_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect NOT_OP calculation" severity error;

    ------------------------------------ LOGIC : NEG ------------------------------------- 
    X <= to_signed(65, 16);
    Y <= to_signed(0, 8);
    CONTROL <= NEG_OP;
    wait for 1 us;
    assert OUTPUT = -65 report "Incorrect NEG calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= OR_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect OR_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-50, 16);
    Y <= to_signed(0, 8);
    CONTROL <= OR_OP;
    wait for 1 us;
    assert OUTPUT(7 downto 0) = -50 report "Incorrect OR_OP calculation" severity error;

    ------------------------------------ Multiplication : MULU ------------------------------------- 
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULU calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= MULU_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect MULU calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(5, 16);
    Y <= to_signed(-1, 8);
    CONTROL <= MULU_OP;
    wait for 1 us;
    assert OUTPUT = 645 report "Incorrect MULU calculation" severity error;

    -- Overflow Test
    X <= to_signed(20000, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULU calculation" severity error;

    -- Carry Test
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULU calculation" severity error;

    ------------------------------------ Multiplication : MULS ------------------------------------- 
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULS_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULS calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= MULS_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect MULS_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(5, 16);
    Y <= to_signed(-1, 8);
    CONTROL <= MULS_OP;
    wait for 1 us;
    assert OUTPUT = -5 report "Incorrect MULS_OP calculation" severity error;

    -- Overflow Test
    X <= to_signed(20000, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULS_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULS_OP calculation" severity error;

    -- Carry Test
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULS_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULS_OP calculation" severity error;

    ------------------------------------ Multiplication : MULSU ------------------------------------- 
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULSU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULSU calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= MULSU_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect MULSU_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-5, 16);
    Y <= to_signed(1, 8);
    CONTROL <= MULSU_OP;
    wait for 1 us;
    assert OUTPUT = -5 report "Incorrect MULSU_OP calculation" severity error;

    -- Overflow Test
    X <= to_signed(20000, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULSU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULSU_OP calculation" severity error;

    -- Carry Test
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= MULSU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULSU_OP calculation" severity error;

    ------------------------------------ Multiplication : FMULU ------------------------------------- 
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULU_OP;
    wait for 1 us;
    assert OUTPUT = 500 report "Incorrect FMULU calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= FMULU_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect FMULU_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(5, 16);
    Y <= to_signed(-1, 8);
    CONTROL <= FMULU_OP;
    wait for 1 us;
    assert OUTPUT = 650 report "Incorrect FMULU_OP calculation" severity error;

    -- Overflow Test
    X <= to_signed(20000, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect FMULU_OP calculation" severity error;

    -- Carry Test
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect FMULU_OP calculation" severity error;

    ------------------------------------ Multiplication : FMULS ------------------------------------- 
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULS_OP;
    wait for 1 us;
    assert OUTPUT = 500 report "Incorrect FMULS calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= FMULS_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect FMULS_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(4, 16);
    Y <= to_signed(-1, 8);
    CONTROL <= FMULS_OP;
    wait for 1 us;
    assert OUTPUT = -8 report "Incorrect FMULS_OP calculation" severity error;

    -- Overflow Test
    X <= to_signed(20000, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULS_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect FMULS_OP calculation" severity error;

    -- Carry Test
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULS_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect FMULS_OP calculation" severity error;

    ------------------------------------ Multiplication : FMULSU ------------------------------------- 
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULSU_OP;
    wait for 1 us;
    assert OUTPUT = 500 report "Incorrect FMULSU calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= FMULSU_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect FMULSU_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-4, 16);
    Y <= to_signed(1, 8);
    CONTROL <= FMULSU_OP;
    wait for 1 us;
    assert OUTPUT = -8 report "Incorrect FMULSU_OP calculation" severity error;

    -- Overflow Test
    X <= to_signed(20000, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULSU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect FMULSU_OP calculation" severity error;

    -- Carry Test
    X <= to_signed(5, 16);
    Y <= to_signed(50, 8);
    CONTROL <= FMULSU_OP;
    wait for 1 us;
    assert OUTPUT = 250 report "Incorrect MULU calculation" severity error;

    ------------------------------------ Shift : LSL ------------------------------------- 
    X <= to_signed(64, 16);
    Y <= to_signed(1, 8);
    CONTROL <= LSL_OP;
    wait for 1 us;
    assert OUTPUT = 128 report "Incorrect LSL calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= LSL_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect LSL_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-4, 16);
    Y <= to_signed(1, 8);
    CONTROL <= LSL_OP;
    wait for 1 us;
    assert OUTPUT = -8 report "Incorrect LSL_OP calculation" severity error;

    ------------------------------------ Shift : LSR ------------------------------------- 
    X <= to_signed(64, 16);
    Y <= to_signed(1, 8);
    CONTROL <= LSR_OP;
    wait for 1 us;
    assert OUTPUT = 32 report "Incorrect LSR_OP calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= LSR_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect LSR_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-4, 16);
    Y <= to_signed(1, 8);
    CONTROL <= LSR_OP;
    wait for 1 us;
    assert OUTPUT = -2 report "Incorrect LSR_OP calculation" severity error;

    ------------------------------------ Shift : ASR ------------------------------------- 
    X <= to_signed(64, 16);
    Y <= to_signed(1, 8);
    CONTROL <= ASR_OP;
    wait for 1 us;
    assert OUTPUT = 32 report "Incorrect ASR calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ASR_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ASR_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-4, 16);
    Y <= to_signed(1, 8);
    CONTROL <= ASR_OP;
    wait for 1 us;
    assert OUTPUT = -2 report "Incorrect ASR_OP calculation" severity error;

    ------------------------------------ Shift : ROTL ------------------------------------- 
    X <= to_signed(64, 16);
    Y <= to_signed(1, 8);
    CONTROL <= ROL_OP;
    wait for 1 us;
    assert OUTPUT = 128 report "Incorrect ROTL calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ROL_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ROL_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-4, 16);
    Y <= to_signed(1, 8);
    CONTROL <= ROL_OP;
    wait for 1 us;
    assert OUTPUT = -8 report "Incorrect ROL_OP calculation" severity error;

    ------------------------------------ Shift : ROTR ------------------------------------- 
    X <= to_signed(64, 16);
    Y <= to_signed(1, 8);
    CONTROL <= ROR_OP;
    wait for 1 us;
    assert OUTPUT = 32 report "Incorrect ROTR calculation" severity error;

    -- Zero Test
    X <= to_signed(0, 16);
    Y <= to_signed(0, 8);
    CONTROL <= ROR_OP;
    wait for 1 us;
    assert OUTPUT = 0 report "Incorrect ROR_OP calculation" severity error;

    -- Negative Test and Sign Test
    X <= to_signed(-4, 16);
    Y <= to_signed(1, 8);
    CONTROL <= ROR_OP;
    wait for 1 us;
    assert OUTPUT = -4 report "Incorrect ROR_OP calculation" severity error;


end process;

DUT: entity work.alu
	port map( 
	X => X, Y => Y, OUTPUT => OUTPUT, CONTROL =>  CONTROL, STATUS_OUT => STATUS_OUT, STATUS_IN => STATUS_IN);
end test;