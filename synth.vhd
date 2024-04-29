library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity UART_RX is
  port (
    CLK: in std_logic;
    RST: in std_logic;
    DIN: in std_logic;
    DOUT: out std_logic_vector (7 downto 0);
    DOUT_VLD: out std_logic
  );
end entity;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_fsm is
  port (
    clk : in std_logic;
    rst : in std_logic;
    stop : in std_logic;
    inp : in std_logic;
    midb : in std_logic;
    re : out std_logic;
    vld : out std_logic);
end entity uart_rx_fsm;

architecture rtl of uart_rx_fsm is
  signal current_state : std_logic_vector (2 downto 0);
  signal next_state : std_logic_vector (2 downto 0);
  signal n89_q : std_logic_vector (2 downto 0);
  signal n91_o : std_logic;
  signal n92_o : std_logic;
  signal n94_o : std_logic_vector (2 downto 0);
  signal n96_o : std_logic;
  signal n98_o : std_logic_vector (2 downto 0);
  signal n100_o : std_logic;
  signal n102_o : std_logic_vector (2 downto 0);
  signal n104_o : std_logic;
  signal n107_o : std_logic_vector (2 downto 0);
  signal n108_o : std_logic_vector (2 downto 0);
  signal n110_o : std_logic;
  signal n112_o : std_logic;
  signal n113_o : std_logic_vector (4 downto 0);
  signal n116_o : std_logic_vector (2 downto 0);
  signal n120_o : std_logic;
  signal n122_o : std_logic;
  signal n124_o : std_logic;
  signal n126_o : std_logic;
  signal n128_o : std_logic;
  signal n129_o : std_logic_vector (4 downto 0);
  signal n136_o : std_logic;
  signal n144_o : std_logic;
begin
  re <= n136_o;
  vld <= n144_o;
  -- uart_rx_fsm.vhd:27:16
  current_state <= n89_q; -- (signal)
  -- uart_rx_fsm.vhd:28:16
  next_state <= n116_o; -- (signal)
  -- uart_rx_fsm.vhd:36:17
  process (clk, rst)
  begin
    if rst = '1' then
      n89_q <= "000";
    elsif rising_edge (clk) then
      n89_q <= next_state;
    end if;
  end process;
  -- uart_rx_fsm.vhd:47:55
  n91_o <= not inp;
  -- uart_rx_fsm.vhd:47:47
  n92_o <= midb and n91_o;
  -- uart_rx_fsm.vhd:47:33
  n94_o <= current_state when n92_o = '0' else "001";
  -- uart_rx_fsm.vhd:46:25
  n96_o <= '1' when current_state = "000" else '0';
  -- uart_rx_fsm.vhd:51:33
  n98_o <= current_state when midb = '0' else "010";
  -- uart_rx_fsm.vhd:50:25
  n100_o <= '1' when current_state = "001" else '0';
  -- uart_rx_fsm.vhd:55:33
  n102_o <= current_state when stop = '0' else "011";
  -- uart_rx_fsm.vhd:54:25
  n104_o <= '1' when current_state = "010" else '0';
  -- uart_rx_fsm.vhd:60:41
  n107_o <= "000" when inp = '0' else "100";
  -- uart_rx_fsm.vhd:59:33
  n108_o <= current_state when midb = '0' else n107_o;
  -- uart_rx_fsm.vhd:58:25
  n110_o <= '1' when current_state = "011" else '0';
  -- uart_rx_fsm.vhd:66:25
  n112_o <= '1' when current_state = "100" else '0';
  n113_o <= n112_o & n110_o & n104_o & n100_o & n96_o;
  -- uart_rx_fsm.vhd:45:17
  with n113_o select n116_o <=
    "000" when "10000",
    n108_o when "01000",
    n102_o when "00100",
    n98_o when "00010",
    n94_o when "00001",
    "XXX" when others;
  -- uart_rx_fsm.vhd:76:25
  n120_o <= '1' when current_state = "000" else '0';
  -- uart_rx_fsm.vhd:79:25
  n122_o <= '1' when current_state = "001" else '0';
  -- uart_rx_fsm.vhd:82:25
  n124_o <= '1' when current_state = "010" else '0';
  -- uart_rx_fsm.vhd:85:25
  n126_o <= '1' when current_state = "011" else '0';
  -- uart_rx_fsm.vhd:88:25
  n128_o <= '1' when current_state = "100" else '0';
  n129_o <= n128_o & n126_o & n124_o & n122_o & n120_o;
  -- uart_rx_fsm.vhd:75:17
  with n129_o select n136_o <=
    '1' when "10000",
    '1' when "01000",
    '0' when "00100",
    '0' when "00010",
    '1' when "00001",
    'X' when others;
  -- uart_rx_fsm.vhd:75:17
  with n129_o select n144_o <=
    '1' when "10000",
    '0' when "01000",
    '0' when "00100",
    '0' when "00010",
    '0' when "00001",
    'X' when others;
end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of uart_rx is
  signal wrap_CLK: std_logic;
  signal wrap_RST: std_logic;
  signal wrap_DIN: std_logic;
  subtype typwrap_DOUT is std_logic_vector (7 downto 0);
  signal wrap_DOUT: typwrap_DOUT;
  signal wrap_DOUT_VLD: std_logic;
  signal din_buf : std_logic_vector (2 downto 0);
  signal shift_register : std_logic_vector (7 downto 0);
  signal cnt_1_order : std_logic_vector (3 downto 0);
  signal midbit : std_logic;
  signal cnt_2_order : std_logic_vector (3 downto 0);
  signal cmp_midbits : std_logic;
  signal re_wire : std_logic;
  signal fsm_re : std_logic;
  signal fsm_vld : std_logic;
  signal n8_o : std_logic;
  signal n13_o : std_logic;
  signal n14_o : std_logic;
  signal n15_o : std_logic_vector (2 downto 0);
  signal n20_q : std_logic_vector (2 downto 0) := "111";
  signal n24_o : std_logic_vector (3 downto 0);
  signal n29_q : std_logic_vector (3 downto 0) := "0000";
  signal n32_o : std_logic;
  signal n35_o : std_logic;
  signal n39_o : std_logic;
  signal n40_o : std_logic;
  signal n41_o : std_logic;
  signal n42_o : std_logic;
  signal n43_o : std_logic;
  signal n44_o : std_logic;
  signal n45_o : std_logic;
  signal n46_o : std_logic;
  signal n47_o : std_logic_vector (7 downto 0);
  signal n52_q : std_logic_vector (7 downto 0) := "00000000";
  signal n54_o : std_logic;
  signal n57_o : std_logic_vector (3 downto 0);
  signal n63_o : std_logic_vector (3 downto 0);
  signal n64_q : std_logic_vector (3 downto 0) := "0000";
  signal n67_o : std_logic;
  signal n70_o : std_logic;
  signal n79_o : std_logic_vector (7 downto 0);
  signal n80_q : std_logic_vector (7 downto 0);
begin
  wrap_clk <= clk;
  wrap_rst <= rst;
  wrap_din <= din;
  dout <= wrap_dout;
  dout_vld <= wrap_dout_vld;
  wrap_DOUT <= n80_q;
  wrap_DOUT_VLD <= fsm_vld;
  -- uart_rx.vhd:26:16
  din_buf <= n20_q; -- (isignal)
  -- uart_rx.vhd:27:16
  shift_register <= n52_q; -- (isignal)
  -- uart_rx.vhd:29:16
  cnt_1_order <= n29_q; -- (isignal)
  -- uart_rx.vhd:30:16
  midbit <= n35_o; -- (isignal)
  -- uart_rx.vhd:31:16
  cnt_2_order <= n64_q; -- (isignal)
  -- uart_rx.vhd:32:16
  cmp_midbits <= n70_o; -- (isignal)
  -- uart_rx.vhd:33:16
  re_wire <= fsm_re; -- (signal)
  -- uart_rx.vhd:39:5
  fsm : entity work.uart_rx_fsm port map (
    clk => wrap_CLK,
    rst => wrap_RST,
    stop => cmp_midbits,
    inp => n8_o,
    midb => midbit,
    re => fsm_re,
    vld => fsm_vld);
  -- uart_rx.vhd:44:23
  n8_o <= din_buf (2);
  -- uart_rx.vhd:56:38
  n13_o <= din_buf (0);
  -- uart_rx.vhd:57:38
  n14_o <= din_buf (1);
  n15_o <= n14_o & n13_o & wrap_DIN;
  -- uart_rx.vhd:54:13
  process (wrap_CLK, wrap_RST)
  begin
    if wrap_RST = '1' then
      n20_q <= "111";
    elsif rising_edge (wrap_CLK) then
      n20_q <= n15_o;
    end if;
  end process;
  -- uart_rx.vhd:66:48
  n24_o <= std_logic_vector (unsigned (cnt_1_order) + unsigned'("0001"));
  -- uart_rx.vhd:65:13
  process (wrap_CLK, wrap_RST)
  begin
    if wrap_RST = '1' then
      n29_q <= "0000";
    elsif rising_edge (wrap_CLK) then
      n29_q <= n24_o;
    end if;
  end process;
  -- uart_rx.vhd:72:28
  n32_o <= '1' when cnt_1_order = "1011" else '0';
  -- uart_rx.vhd:72:13
  n35_o <= '0' when n32_o = '0' else '1';
  -- uart_rx.vhd:85:49
  n39_o <= din_buf (2);
  -- uart_rx.vhd:87:70
  n40_o <= shift_register (1);
  -- uart_rx.vhd:87:70
  n41_o <= shift_register (2);
  -- uart_rx.vhd:87:70
  n42_o <= shift_register (3);
  -- uart_rx.vhd:87:70
  n43_o <= shift_register (4);
  -- uart_rx.vhd:87:70
  n44_o <= shift_register (5);
  -- uart_rx.vhd:87:70
  n45_o <= shift_register (6);
  -- uart_rx.vhd:87:70
  n46_o <= shift_register (7);
  n47_o <= n39_o & n46_o & n45_o & n44_o & n43_o & n42_o & n41_o & n40_o;
  -- uart_rx.vhd:84:13
  process (midbit, wrap_RST)
  begin
    if wrap_RST = '1' then
      n52_q <= "00000000";
    elsif rising_edge (midbit) then
      n52_q <= n47_o;
    end if;
  end process;
  -- uart_rx.vhd:95:26
  n54_o <= wrap_RST or re_wire;
  -- uart_rx.vhd:99:56
  n57_o <= std_logic_vector (unsigned (cnt_2_order) + unsigned'("0001"));
  -- uart_rx.vhd:97:13
  n63_o <= cnt_2_order when midbit = '0' else n57_o;
  -- uart_rx.vhd:97:13
  process (wrap_CLK, n54_o)
  begin
    if n54_o = '1' then
      n64_q <= "0000";
    elsif rising_edge (wrap_CLK) then
      n64_q <= n63_o;
    end if;
  end process;
  -- uart_rx.vhd:106:28
  n67_o <= '1' when cnt_2_order = "1000" else '0';
  -- uart_rx.vhd:106:13
  n70_o <= '0' when n67_o = '0' else '1';
  -- uart_rx.vhd:117:13
  n79_o <= n80_q when cmp_midbits = '0' else shift_register;
  -- uart_rx.vhd:117:13
  process (wrap_CLK, wrap_RST)
  begin
    if wrap_RST = '1' then
      n80_q <= "00000000";
    elsif rising_edge (wrap_CLK) then
      n80_q <= n79_o;
    end if;
  end process;
end rtl;
