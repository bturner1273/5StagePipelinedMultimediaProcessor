-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RegisterFile is
port(
writeEnable : in std_logic;
readReg1 : in std_logic_vector(4 downto 0);--4 downto 0 because
readReg2 : in std_logic_vector(4 downto 0);--we have 32 registers
readReg3 : in std_logic_vector(4 downto 0);--to choose from
writeReg : in std_logic_vector(4 downto 0);
dataIn : in std_logic_vector(63 downto 0);
out1, out2, out3, rdDataOut : out std_logic_vector(63 downto 0));
end RegisterFile;

architecture behavioral of RegisterFile is
type registerFile is array(0 to 31) of std_logic_vector(63 downto 0);
signal registers : registerFile;

begin

write : process(writeEnable,registers,writeReg,dataIn)
begin
if writeEnable = '1' then
registers(to_integer(unsigned(writeReg))) <= dataIn;
end if;
end process write;

read : process(readReg1,readReg2,readReg3,registers)
begin
rdDataOut <= registers(to_integer(unsigned(writeReg)));
out1 <= registers(to_integer(unsigned(readReg1)));
out2 <= registers(to_integer(unsigned(readReg2)));
out3 <= registers(to_integer(unsigned(readReg3)));
end process read;

end behavioral;
