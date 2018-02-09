-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
--empty entity
end testbench;

architecture tb of testbench is

--UUT component
component RegisterFile is 
port(
writeEnable : in std_logic;
readReg1 : in std_logic_vector(4 downto 0);--4 downto 0 because
readReg2 : in std_logic_vector(4 downto 0);--we have 32 registers
readReg3 : in std_logic_vector(4 downto 0);--to choose from
writeReg : in std_logic_vector(4 downto 0);
dataIn : in std_logic_vector(63 downto 0);
out1, out2, out3, rdDataOut : out std_logic_vector(63 downto 0));
end component;

--define signals
signal writeEnable : std_logic;
signal readReg1,readReg2,readReg3,writeReg : std_logic_vector(4 downto 0);
signal dataIn,out1,out2,out3,rdDataOut : std_logic_vector(63 downto 0);

begin

UUT : RegisterFile port map(writeEnable, readReg1, readReg2, readReg3, writeReg, dataIn, out1, out2, out3, rdDataOut);


process
begin
wait for 1 ns;
writeEnable <= '1';
dataIn <= x"FFFFFFFFFFFFFFFF";
writeReg <= "01000";
readReg1 <= "01000";
wait for 1 ns;
dataIn <= x"AAAAAAAAAAAAAAAA";
writeReg <= "01010";
readReg2 <= "01010";
wait for 1 ns;
dataIn <= x"ABCABCABC123123A";
writeReg <= "01011";
readReg3 <= "01011";
wait for 1 ns;
wait;
end process;
end tb;



