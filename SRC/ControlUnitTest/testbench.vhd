-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
--empty entity
end testbench;

architecture tb of testbench is
--define component
component Control is
port(
controlControl : in std_logic_vector(8 downto 0);
liLocation, aluControl, MAMS : out std_logic_vector(1 downto 0);
regWrite : out std_logic;
opCode : out std_logic_vector(6 downto 0));
end component;

--define signals
signal controlControl : std_logic_vector(8 downto 0);
signal liLocation, aluControl, MAMS : std_logic_vector(1 downto 0);
signal regWrite : std_logic;
signal opCode : std_logic_vector(6 downto 0);

--begin testbench
begin

--map UUT
UUT : Control port map(controlControl, liLocation, aluControl, MAMS, regWrite, opCode);

process
begin
wait for 1 ns;
controlControl <= "010011111";
wait for 5 ns;
controlControl <= "010111111";
wait for 5 ns;
controlControl <= "011011111";
wait for 5 ns;
controlControl <= "011111111";
wait for 5 ns;
controlControl <= "101111111";
wait for 5 ns;
controlControl <= "000000000";
wait for 5 ns;
controlControl <= "000000001";
wait for 5 ns;
wait;
end process;
end tb;

