-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity FullInstructionBuffer is
port(
initAddress : in std_logic_vector(4 downto 0);
clock, reset : in std_logic;
instruction : out std_logic_vector(23 downto 0));
end FullInstructionBuffer;

architecture behavioral of FullInstructionBuffer is
--define components and signals

component instructionBuffer is 
port(
-- assuming 32 lines of instructions in a file
		line_no : in STD_LOGIC_VECTOR(4 downto 0);
		-- 24 bit instructions
		value : out STD_LOGIC_VECTOR(23 downto 0));
end component;

component programCounter is
port(
	pc : in std_logic_vector(4 downto 0);
	next_pc : out std_logic_vector(4 downto 0));
end component;

component instructionAddress is
port(
		clk : in std_logic; 
		rst_bar : in std_logic;
		defaultAddress : in std_logic_vector(4 downto 0);
		address_in : in STD_LOGIC_VECTOR(4 downto 0);
		address_out : out STD_LOGIC_VECTOR(4 downto 0));
end component;

signal address_out, next_pc : std_logic_vector(4 downto 0);

--connect UUTs
begin
pc : programCounter port map(address_out, next_pc);

inst_addr : instructionAddress port map(clock, reset, initAddress, next_pc, address_out);


inst_buff : instructionBuffer port map(address_out, instruction);

end behavioral;