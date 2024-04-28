-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 



entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       STOP: in std_logic;
       INP : in std_logic;
       MIDB: in std_logic;
       RE  : out std_logic; --so that we  Stopwriting to register after Stop
       VLD : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
    	type STATE_T is (idle, start, read, Stopp, valid);

	signal current_state: STATE_T;
	signal next_state: STATE_T;
begin


	proc_cstate: process(CLK, RST, next_state) is --set current state
	begin
		if RST = '1' then
			current_state <= idle;
		elsif CLK'event and CLK = '1' then
			current_state <= next_state;
		end if;
	end process;


	nstate_logic: process(current_state, STOP, INP, MIDB) is --set next state
	begin
		next_state <= current_state;
		case current_state is
			when idle =>
				if MIDB = '1' and INP = '0' then
					next_state <= start;
				end if;
			when start =>
				if MIDB = '1' then
					next_state <= read;
				end if;
			when read =>
				if STOP = '1' then
					next_state <= Stopp;
				end if;
			when Stopp =>
				if MIDB = '1' then
					if INP = '1' then
						next_state <= valid;
					else
						next_state <= idle;
					end if;
				end if;
			when valid =>
				next_state <= idle;
		end case;
	end process;

	output_logic: process(current_state) is
	begin
		RE <= '1';
		VLD <= '0';
		case current_state is
			when idle =>
				RE <= '1';
				VLD <= '0';
			when start =>
				RE <= '0';
				VLD <= '0';
			when read =>
				RE <= '0';
				VLD <= '0';
			when Stopp =>
				RE <= '1';
				VLD <= '0';
			when valid =>
				RE <= '1';
				VLD <= '1';
		end case;
	end process;
		

end architecture;
