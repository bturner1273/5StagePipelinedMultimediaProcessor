-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
--empty entity
end testbench;


architecture tb of testbench is
--init component and signals

signal initAddress : std_logic_vector(4 downto 0);
signal reset : std_logic;
signal clock : std_logic := '0';
signal instruction : std_logic_vector(23 downto 0);

component FullInstructionBuffer is
port(
initAddress : in std_logic_vector(4 downto 0);
clock, reset : in std_logic;
instruction : out std_logic_vector(23 downto 0));
end component;


begin

--map UUT
UUT : FullInstructionBuffer port map(initAddress, clock, reset, instruction);

process(clock)
begin
clock <= not clock after 500 ps;
end process;

stop_simulation :process
begin
   wait for 100 ns; --run the simulation for this duration
   assert false
       report "simulation ended"
       severity failure;
end process;

process
begin
reset <= '0', '1' after 100ps;
initAddress <= "00000";
wait for 100 ns;
end process;

end tb;
