library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use std.textio.all;		
use ieee.numeric_std.all; 
--library text_lib;
use txt_util.all;

entity testbench is
end testbench;

architecture tb of testbench is
    signal clock: std_logic := '0';
    signal reset: std_logic;
    signal initialAddress : std_logic_vector(4 downto 0);

    signal aluOut : std_logic_vector(63 downto 0);
    --PORTS JUST FOR WAVE DUMP--
    --Fetch
    signal instruction : std_logic_vector(23 downto 0);
    --IF/ID
    signal controlOut : std_logic_vector(8 downto 0);
    signal r1Out,r2Out,r3Out,writeRegOut : std_logic_vector(4 downto 0);
    signal immediateOut : std_logic_vector(15 downto 0);
    --ID/EX
    signal aluControlOut, MAMSOut, liLocationOut : std_logic_vector(1 downto 0);
    signal opCodeOut : std_logic_vector(6 downto 0);
    signal immediateOut1 : std_logic_vector(15 downto 0);
    signal r1Outd,r2Outd,r3Outd,writeRegOutd : std_logic_vector(63 downto 0);
    signal regWriteOut : std_logic;
    signal writeRegNumOut : std_logic_vector(4 downto 0);
    signal forward1, forward2, forward3 : std_logic;

    constant period:time:=1 ns;
    
    component Processor is
port(
clock, reset : in std_logic;
initialAddress : in std_logic_vector(4 downto 0);
aluOut : out std_logic_vector(63 downto 0);

--for wave dump
instruction : out std_logic_vector(23 downto 0);
controlOut : out std_logic_vector(8 downto 0);
r1Out,r2Out,r3Out,writeRegOut : out std_logic_vector(4 downto 0);
immediateOut : out std_logic_vector(15 downto 0);
aluControlOut, MAMSOut, liLocationOut : out std_logic_vector(1 downto 0);
opCodeOut : out std_logic_vector(6 downto 0);
immediateOut1 : out std_logic_vector(15 downto 0);
r1Outd,r2Outd,r3Outd,writeRegOutd : out std_logic_vector(63 downto 0);
regWriteOut : out std_logic;
writeRegNumOut : out std_logic_vector(4 downto 0);
forward1, forward2, forward3 : out std_logic);
end component;

begin
    UUT : Processor port map(
        clock => clock, reset => reset,
        initialAddress => initialAddress,
        aluOut => aluOut,
        instruction => instruction,
        controlOut => controlOut,
        r1Out => r1Out, r2Out => r2Out, r3Out => r3Out, writeRegOut => writeRegOut,
        immediateOut => immediateOut,
        aluControlOut => aluControlOut, MAMSOut => MAMSOut, liLocationOut => liLocationOut,
        opCodeOut => opCodeOut,
        immediateOut1 => immediateOut1,
        r1Outd => r1Outd, r2Outd => r2Outd, r3Outd => r3Outd, writeRegOutd => writeRegOutd,
        regWriteOut => regWriteOut,
        writeRegNumOut => writeRegNumOut,forward1 => forward1,forward2 => forward2,forward3 => forward3
        );
    
    process(clock)
    begin
        clock <= not clock after 500 ps;
    end process;

    stop_simulation:process
    begin
        wait for 40 ns; --run the simulation for this duration
        assert false
        report "simulation ended"
        severity failure;
    end process;
    
    
    a:process
    begin
        initialAddress <= "00000";
        reset <= '0', '1' after period;
        wait;
    end process;
    
    
    write_file:process
        file outfile:text;
        variable instr_type:string(1 to 2);
        variable idex_op:string(1 to 7);
        variable exwb_op:string(1 to 7);
    begin
        file_open(outfile,"result.txt",write_mode);
        for j in 1 to 32 loop
            wait for period;
            
            case instruction(23 downto 22) is
                when "10"=> instr_type := "R1";
                when "11"=> instr_type := "R1";
                when "01"=> instr_type := "R4";
                when "00"=> instr_type := "R3";
                when others=> instr_type := "UU";
            end case;
            
            --assume IF/ID (ID/EX, 2nd stage) is opcode
            case controlOut(3 downto 0) is
                when "0000"=>idex_op:="nop    ";
                when "0001"=>idex_op:="bcw    ";
                when "0010"=>idex_op:="and    ";
                when "0011"=>idex_op:="or     ";
                when "0100"=>idex_op:="popcnth";
                when "0101"=>idex_op:="clz    ";
                when "0110"=>idex_op:="rot    ";
                when "0111"=>idex_op:="shlhi  ";
                when "1000"=>idex_op:="a      ";
                when "1001"=>idex_op:="sfw    ";
                when "1010"=>idex_op:="ah     ";
                when "1011"=>idex_op:="sfh    ";
                when "1100"=>idex_op:="ahs    ";
                when "1101"=>idex_op:="sfhs   ";
                when "1110"=>idex_op:="mpyu   ";
                when "1111"=>idex_op:="absdb  ";
                when others=>idex_op:="UUUUUUU";    
            end case;
        
            --assume ID/EX (EX/WB, 3rd Stage) is opcode
            case opCodeOut(3 downto 0) is
                when "0000"=>exwb_op:="nop    ";
                when "0001"=>exwb_op:="bcw    ";
                when "0010"=>exwb_op:="and    ";
                when "0011"=>exwb_op:="or     ";
                when "0100"=>exwb_op:="popcnth";
                when "0101"=>exwb_op:="clz    ";
                when "0110"=>exwb_op:="rot    ";
                when "0111"=>exwb_op:="shlhi  ";
                when "1000"=>exwb_op:="a      ";
                when "1001"=>exwb_op:="sfw    ";
                when "1010"=>exwb_op:="ah     ";
                when "1011"=>exwb_op:="sfh    ";
                when "1100"=>exwb_op:="ahs    ";
                when "1101"=>exwb_op:="sfhs   ";
                when "1110"=>exwb_op:="mpyu   ";
                when "1111"=>exwb_op:="absdb  ";
                when others=>exwb_op:="UUUUUUU";    
            end case;
        
            print(outfile, "Clock Cycle: " & str(j));
            print(outfile, "IF/ID");
            print(outfile, "Instruction: " & hstr(instruction) & "      Type: " & instr_type);
            print(outfile, " ");
            print(outfile, "ID/EX");
            
            if controlOut(8 downto 7) = "10" then
                print(outfile, "Type: R1 " & "  li location: " & str(controlOut(7 downto 6)) & "    imm: " & hstr(immediateOut));
            elsif controlOut(8 downto 7) = "01" then
                print(outfile, "Type: R4 " & "  MAMS: " & str(controlOut(6 downto 5)) & "    rs1_addr: " & hstr(r1Out) & "   rs2_addr: " & hstr(r2Out) & "   rs3_addr: " & hstr(r3Out) & "   rd_addr: " & hstr(writeRegOut));
            elsif controlOut(8 downto 7) = "00" then
                print(outfile, "Type: R3 " & "  Opcode: " & idex_op & "     rs1_addr: " & hstr(r1Out) & "    rs2_addr: " & hstr(r2Out) & "     rd_addr: " & hstr(writeRegOut));  
            else
                print(outfile, "Type: UU");
            end if;
        
            print(outfile, " ");
            print(outfile, "EX/WB");
        
            if aluControlOut = "10" then
                print(outfile, "Type: R1 " & "  li location: " & hstr(liLocationOut) & "   imm: " & hstr(immediateOut1));
            elsif aluControlOut = "01" then
                print(outfile, "Type: R4 " & "MAMS: " & hstr(MAMSOut) & "   rs1_data: " & hstr(r1Outd) & "  rs2_data: " & hstr(r2Outd) & "  rs3_data: " & hstr(r3Outd) & "  rd_addr: " & hstr(writeRegOut));
            elsif aluControlOut = "00" then
                print(outfile, "Type: R3" & "   Opcode: " & exwb_op & "    rs1_data: " & hstr(r1Outd) & "   rs2_data: " & hstr(r2Outd) & "  rd_addr: " & hstr(writeRegNumOut) & "   ALU_out: " & hstr(aluOut));
            else
                print(outfile, "Type: UU");
            end if;
        
            print(outfile, " ");
            print(outfile, " ");
    
        end loop;
        file_close(outfile);
        wait;
    end process write_file;

end tb;