-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity ForwardingUnit is
port(
IFIDrs1, IFIDrs2, IFIDrs3, IDEXrd : in std_logic_vector(4 downto 0);
forward1, forward2, forward3 : out std_logic;
writeReg : in std_logic);
end ForwardingUnit;

architecture behavioral of ForwardingUnit is
begin
process(writeReg, IDEXrd, IFIDrs1, IFIDrs2, IFIDrs3)
begin
if IDEXrd = IFIDrs1 and writeReg = '1' then
forward1 <= '1';
else
forward1 <= '0';
end if;

if IDEXrd = IFIDrs2 and writeReg = '1' then
forward2 <= '1';
else
forward2 <= '0';
end if;

if IDEXrd = IFIDrs2 and writeReg = '1' then
forward3 <= '1';
else 
forward3 <= '0';
end if;
end process;
end behavioral;