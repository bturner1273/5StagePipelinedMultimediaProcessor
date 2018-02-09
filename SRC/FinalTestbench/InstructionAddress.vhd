library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity instructionAddress is
	port( 
		clk:in std_logic; 
		rst_bar:in std_logic;
		defaultAddress : in std_logic_vector(4 downto 0);
		address_in: in STD_LOGIC_VECTOR(4 downto 0);
		address_out: out STD_LOGIC_VECTOR(4 downto 0)
	    );
end instructionAddress;

architecture instruction_address_arch of instructionAddress is	  
begin
	process(rst_bar,clk,address_in)
	begin	  
		if rst_bar = '0' then
			address_out <= defaultAddress;
		elsif rising_edge(clk) then
			address_out <= address_in;
		end if;
	end process;
end instruction_address_arch;