-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
--empty entity
end testbench;

architecture tb of testbench is
component ForwardingUnit is
port(
IFIDrs1, IFIDrs2, IFIDrs3, IDEXrd : in std_logic_vector(4 downto 0);
forward1, forward2, forward3 : out std_logic;
writeReg : in std_logic);
end component;

signal IFIDrs1, IFIDrs2, IFIDrs3, IDEXrd : std_logic_vector(4 downto 0);
signal forward1, forward2, forward3, writeReg : std_logic;

begin
UUT : ForwardingUnit port map(IFIDrs1, IFIDrs2, IFIDrs3, IDEXrd, forward1, forward2, forward3, writeReg);

process
begin
IFIDrs1 <= "10101";
IFIDrs2 <= "10001";
IFIDrs3 <= "11000";
IDEXrd <=  "00000";
writeReg <= '1';
wait for 1 ns;
IFIDrs1 <= "10101";
IFIDrs2 <= "10001";
IFIDrs3 <= "11000";
IDEXrd <=  "10101";
wait for 1 ns;
IFIDrs1 <= "10101";
IFIDrs2 <= "10001";
IFIDrs3 <= "11000";
IDEXrd <=  "10001";
wait for 1 ns;
IFIDrs1 <= "10101";
IFIDrs2 <= "10001";
IFIDrs3 <= "11000";
IDEXrd <=  "11000";
wait for 1 ns;
IFIDrs1 <= "10101";
IFIDrs2 <= "10101";
IFIDrs3 <= "10101";
IDEXrd <=  "10101";
wait for 1 ns;
writeReg <= '0';
wait for 1 ns;
wait;
end process;
end tb;
