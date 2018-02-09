-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity IfId is
port(
inst : in std_logic_vector(23 downto 0);
controlOut : out std_logic_vector(8 downto 0);
r1Out : out std_logic_vector(4 downto 0);
r2Out : out std_logic_vector(4 downto 0);
r3Out : out std_logic_vector(4 downto 0);
writeRegOut : out std_logic_vector(4 downto 0);
immOut : out std_logic_vector(15 downto 0);
clock : in std_logic);
end IfId;

architecture behavioral of IfId is
begin
process(clock, inst)
begin
if rising_edge(clock) then
controlOut <= inst(23 downto 15);
r3Out <= inst(19 downto 15);
r2Out <= inst(14 downto 10);
r1Out <= inst(9 downto 5);
writeRegOut <= inst(4 downto 0);
immOut <= inst(20 downto 5);
end if;
end process;
end behavioral;