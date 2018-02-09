-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity Control is
port(
controlControl : in std_logic_vector(8 downto 0);
liLocation, aluControl, MAMS : out std_logic_vector(1 downto 0);
regWrite : out std_logic;
opCode : out std_logic_vector(6 downto 0));
end Control;

architecture behavioral of Control is
begin
process(controlControl)
begin
aluControl <= controlControl(8 downto 7);
if controlControl(8 downto 7) = "1X" then
regWrite <= '1';
liLocation <= controlControl(7 downto 6);
elsif controlControl(8 downto 7) = "01" then
MAMS <= controlControl(6 downto 5);
regWrite <= '1';
elsif controlControl(8 downto 7) = "00" then
if controlControl(6 downto 0) = "XXX0000" then
regWrite <= '0';
else regWrite <= '1';
end if;
opCode <= controlControl(6 downto 0);
end if;
end process;
end behavioral;


