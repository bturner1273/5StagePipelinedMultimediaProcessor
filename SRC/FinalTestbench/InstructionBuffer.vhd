library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use ieee.numeric_std.all;
use std.textio.all;


entity instructionBuffer is
	port(
		-- assuming 32 lines of instructions in a file
		line_no: in STD_LOGIC_VECTOR(4 downto 0);
		-- 24 bit instructions
		value: out STD_LOGIC_VECTOR(23 downto 0)
		);
end instructionBuffer;

architecture instructionBuffer_arch of instructionBuffer is
	-- 32 x 24bit	
	type reg is array (0 to 31) of std_logic_vector(23 downto 0);
	signal input_buffer: reg; 
begin
	a:process(line_no)
	begin
		value<=input_buffer(to_integer(unsigned(line_no)));	  
	end process a; 
	
	b:process
		file readfile: text;
		variable buff: line;
		variable instructions : bit_vector(23 downto 0);
	begin
		-- specify the location of the instructions text 
		file_open(readfile,"instructions.txt",read_mode);
		for i in 0 to 31 loop
			if (not endfile(readfile)) then
				readline(readfile,buff);	
				read(buff,instructions);
				input_buffer(i)<= to_stdlogicvector(instructions);		
			else
				exit;
			end if;
		end loop;
		file_close(readfile);
		
		wait;
	end process b;
end instructionBuffer_arch;