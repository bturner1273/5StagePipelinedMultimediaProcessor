-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity IdEx is 
port(
clock : in std_logic;
aluControl : in std_logic_vector(1 downto 0);
MAMS : in std_logic_vector(1 downto 0);
opCode : in std_logic_vector(6 downto 0);
regWrite : in std_logic;
writeRegNumber : in std_logic_vector(4 downto 0); --this is IDEXrd
r1, r2, r3, rdData : in std_logic_vector(63 downto 0);
immediate : in std_logic_vector(15 downto 0);
liLocation : in std_logic_vector(1 downto 0);
--for data forwarding
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
end IdEx;


architecture behavioral of IdEx is
begin 
process(clock)
begin
if rising_edge(clock) then
writeRegNumOut <= writeRegNumber;
aluControlOut <= aluControl;
MAMSOut <= MAMS;
opCodeOut <= opCode;
regWriteOut <= regWrite;
rdDataOut <= rdData;
immediateOut <= immediate;
liLocationOut <= liLocation;
end if;
end process;

--STILL NEED FORWARDING PROCESS
process(clock, forward1, forward2, forward3)
begin
--forward r1 if necessary
if rising_edge(clock) then
if forward1 = '1' then
r1Out <= forwardData;
else
r1Out <= r1;
end if;
--forward r2 if necessary
if forward2 = '1' then
r2Out <= forwardData;
else
r2Out <= r2;
end if;
--forward r3 if necessary
if forward3 = '1' then
r3Out <= forwardData;
else
r3Out <= r3;
end if;
end if;
end process;
end behavioral;