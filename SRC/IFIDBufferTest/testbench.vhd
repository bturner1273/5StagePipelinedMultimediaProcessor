-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
--empty entity
end testbench;

architecture tb of testbench is

--instantiate component
component IfId is
port(
inst : in std_logic_vector(23 downto 0);
controlOut : out std_logic_vector(8 downto 0);
r1Out : out std_logic_vector(4 downto 0);
r2Out : out std_logic_vector(4 downto 0);
r3Out : out std_logic_vector(4 downto 0);
writeRegOut : out std_logic_vector(4 downto 0);
immOut : out std_logic_vector(15 downto 0);
clock : in std_logic);
end component;

--define signals
signal clock : std_logic := '0';
signal inst : std_logic_vector(23 downto 0);
signal controlOut : std_logic_vector(8 downto 0);
signal r1Out, r2Out, r3Out, writeRegOut : std_logic_vector(4 downto 0);
signal immOut : std_logic_vector(15 downto 0);

--begin tb
begin

--map UUT
UUT : IfId port map(inst, controlOut, r1Out, r2Out, r3Out, writeRegOut, immOut, clock);

process(clock)
begin
clock <= not clock after 500 ps;
end process;

stop_simulation :process
begin
   wait for 7 ns; --run the simulation for this duration
   assert false
       report "simulation ended"
       severity failure;
end process;

process
begin
inst <= x"ABCDEF";
wait for 1 ns;
inst <= x"FEDCBA";
wait for 1 ns;
inst <= x"12AB6C";
wait for 1 ns;
inst <= x"EBCD6E";
wait for 1 ns;
inst <= x"122222";
wait for 1 ns;
inst <= x"B67111";
wait;
end process;
end tb;
