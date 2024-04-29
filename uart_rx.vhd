-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; --I added



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
	signal DIN_BUF: std_logic_vector(2 downto 0) := "111"; --bear with asynchronity
	signal shift_register: std_logic_vector(7 downto 0) := "00000000";
	--signal DOUT_BUF: std_logic_vector(7 downto 1) := "00000000";
	signal cnt_1_order: std_logic_vector(3 downto 0) := "0000"; --first counter (before midbit comparator)
	signal midbit: std_logic := '0'; --midbit
	signal cnt_2_order: std_logic_vector(3 downto 0) := "0000"; --counts midbits
	signal cmp_midbits: std_logic := '0'; --compares midbits count
	signal re_wire: std_logic;
    	--DOUT := (others => '0');
    	--DOUT_VLD := '0';
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
	STOP => cmp_midbits,
    	INP => DIN_BUF(2),
    	MIDB => midbit,
    	RE => re_wire,
    	VLD => DOUT_VLD
    );

    din_buff: process(CLK, RST) is
    begin
	    if RST = '1' then
		    DIN_BUF <= "111";
	    elsif CLK'event and CLK = '1' then
	    	DIN_BUF(0) <= DIN;
	    	DIN_BUF(1) <= DIN_BUF(0);
	    	DIN_BUF(2) <= DIN_BUF(1);
	    end if;
    end process;

    cnt_1: process(CLK, RST) is
    begin
	    if RST = '1' then
		    cnt_1_order <= "0000";
	    elsif CLK'event and CLK = '1' then
		    cnt_1_order <= cnt_1_order + 1;
	    end if;
    end process;

    cmp_1: process(cnt_1_order) is
    begin
	    if cnt_1_order = "1011" then --3 clocks for synchronisation +8 as a half-bit
		    midbit <= '1';
	    else
		    midbit <= '0';
	    end if;
    end process;

    nbit_shr: process(CLK, RST) is
    begin
	    if RST = '1' then
		    shift_register <= "00000000";
		    --DOUT_BUF <= "00000000";
	    elsif CLK'event and CLK = '1'then
		    if midbit = '1' then
	            	shift_register(7) <= DIN_BUF(2);
	    	    	for index in 1 to 7 loop
		            shift_register(index-1) <= shift_register(index);
	    	    	end loop;
		    end if;
		    --DOUT_BUF <= shift_register;
	    end if;
    end process;

    cnt_2: process(CLK, re_wire, RST) is
    begin
	    if RST = '1' or re_wire = '1' then
		    cnt_2_order <= "0000";
	    elsif CLK'event and CLK = '1' then
		    if midbit = '1' then
			    cnt_2_order <= cnt_2_order + 1;
		    end if;
	    end if;
    end process;

    cmp_2: process(cnt_2_order) is
    begin
	    if cnt_2_order = "1000" then
		    cmp_midbits <= '1';
	    else
		    cmp_midbits <= '0';
	    end if;
    end process;

    dout_reg: process(CLK, RST) is
    begin
	    if RST = '1' then
		    DOUT <= "00000000";
	    elsif CLK'event and CLK = '1' then
		    if cmp_midbits = '1' then
			    DOUT <= shift_register;
		    end if;
	    end if;
    end process;




end architecture;
