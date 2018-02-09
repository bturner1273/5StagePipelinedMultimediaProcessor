-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
--empty entity
end testbench;

architecture tb of testbench is
--define component
component IdEx is
port(
clock : in std_logic;
aluControl : in std_logic_vector(1 downto 0);
MAMS : in std_logic_vector(1 downto 0);
opCode : in std_logic_vector(6 downto 0);
regWrite : in std_logic;
writeRegNumber : in std_logic_vector(4 downto 0);
r1, r2, r3, rdData : in std_logic_vector(63 downto 0);
immediate : in std_logic_vector(15 downto 0);
liLocation : in std_logic_vector(1 downto 0);
forward1, forward2, forward3 : in std_logic;
forwardData : in std_logic_vector(63 downto 0);
aluControlOut : out std_logic_vector(1 downto 0);
MAMSOut : out std_logic_vector(1 downto 0);
opCodeOut : out std_logic_vector(6 downto 0);
regWriteOut : out std_logic;
r1Out, r2Out, r3Out, rdDataOut : out std_logic_vector(63 downto 0);
writeRegNumOut : out std_logic_vector(4 downto 0);
immediateOut : out std_logic_vector(15 downto 0);
liLocationOut : out std_logic_vector(1 downto 0));
end component;

--define signals
signal clock : std_logic := '0';
signal aluControl, MAMS, liLocation, aluControlOut, MAMSOut, liLocationOut : std_logic_vector(1 downto 0);
signal regWrite, regWriteOut : std_logic;
signal writeRegNumber, writeRegNumOut : std_logic_vector(4 downto 0);
signal forward1, forward2, forward3 : std_logic;
signal forwardData : std_logic_vector(63 downto 0);
signal opCode, opCodeOut : std_logic_vector(6 downto 0);
signal r1, r2, r3, rdData, r1Out, r2Out, r3Out, rdDataOut : std_logic_vector(63 downto 0);
signal immediate, immediateOut : std_logic_vector(15 downto 0);

--start tb
begin

--map UUT
UUT : IdEx port map(clock, aluControl, MAMS, opCode, regWrite, writeRegNumber, r1, r2, r3, rdData, immediate, liLocation, forward1, forward2, forward3, forwardData, aluControlOut, MAMSOut, opCodeOut, regWriteOut, r1Out, r2Out, r3Out, rdDataOut, writeRegNumOut, immediateOut, liLocationOut);

process(clock)
begin
clock <= not clock after 500 ps;
end process;

stop_simulation :process
begin
   wait for 35 ns; --run the simulation for this duration
   assert false
       report "simulation ended"
       severity failure;
end process;

process
begin
writeRegNumber <= "10000";
aluControl <= "10";
MAMS <= "10";
opCode <= "1010101";
regWrite <= '1';
r1 <= x"FFFFFFFFFFFFFFFF";
r2 <= x"FFFFFFFFFFFFFFFF";
r3 <= x"FFFFFFFFFFFFFFFF";
rdData <= x"FFFFFFFFFFFFFFFF";
immediate <= x"FFFF";
liLocation <= "10"; 
wait for 10 ns;
forward1 <= '1';
forwardData <= x"0000000000000000";
wait for 10 ns;
r1 <= x"ABCABCABC123123A";
r2 <= x"ABCABCABC123123A";
r3 <= x"ABCABCABC123123A";
rdData <= x"ABCABCABC123123A";
wait for 10 ns;
wait;
end process;
end tb;