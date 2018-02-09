library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity programCounter is port(
	pc: 	 in std_logic_vector(4 downto 0);
	next_pc: out std_logic_vector(4 downto 0)
	);
end programCounter;

architecture programCounter_arch of programCounter is
begin 
	next_pc <= std_logic_vector(to_unsigned(to_integer(unsigned(pc))+1,5));
end programCounter_arch;