-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity Processor is
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
end Processor;

architecture structural of Processor is

component FullInstructionBuffer is 
port(
initAddress : in std_logic_vector(4 downto 0);
clock, reset : in std_logic;
instruction : out std_logic_vector(23 downto 0));
end component;

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

component RegisterFile is 
port(
writeEnable : in std_logic;
readReg1 : in std_logic_vector(4 downto 0);--4 downto 0 because
readReg2 : in std_logic_vector(4 downto 0);--we have 32 registers
readReg3 : in std_logic_vector(4 downto 0);--to choose from
writeReg : in std_logic_vector(4 downto 0);
dataIn : in std_logic_vector(63 downto 0);
out1, out2, out3, rdDataOut : out std_logic_vector(63 downto 0));
end component;

component Control is
port(
controlControl : in std_logic_vector(8 downto 0);
liLocation, aluControl, MAMS : out std_logic_vector(1 downto 0);
regWrite : out std_logic;
opCode : out std_logic_vector(6 downto 0));
end component;

component IdEx is
port(
clock : in std_logic;
aluControl : in std_logic_vector(1 downto 0);
MAMS : in std_logic_vector(1 downto 0);
opCode : in std_logic_vector(6 downto 0);
regWrite : in std_logic;
writeRegNumber : in std_logic_vector(4 downto 0); --this is IDEXrd
r1, r2, r3, rdData : in std_logic_vector(63 downto 0);
immediate : in std_logic_vector(15 downto 0);
liLocation : in std_logic_vector(1 downto 0);
--for data forwarding
forward1, forward2, forward3 : in std_logic;
forwardData : in std_logic_vector(63 downto 0);
aluControlOut : out std_logic_vector(1 downto 0);
MAMSOut : out std_logic_vector(1 downto 0);
opCodeOut : out std_logic_vector(6 downto 0);
regWriteOut : out std_logic;
r1Out, r2Out, r3Out, rdDataOut : out std_logic_vector(63 downto 0);
writeRegNumOut : out std_logic_vector(4 downto 0);
immediateOut : out std_logic_vector(15 downto 0);
liLocationOut : out std_logic_vector(1 downto 0));
end component;

component alu is
port(
	opcode: in STD_LOGIC_VECTOR(6 downto 0);  -- 7bit opcode
	rs1_data: in STD_LOGIC_VECTOR(63 downto 0);
	rs2_data: in STD_LOGIC_VECTOR(63 downto 0);
    -----------------------------------------------
    rs3_data: in STD_LOGIC_VECTOR(63 downto 0);
    ALUcontrol_in: in STD_LOGIC_VECTOR(1 downto 0);
    MAMS_in: in STD_LOGIC_VECTOR(1 downto 0);
    imm_in: in STD_LOGIC_VECTOR(15 downto 0);
    li_location: in STD_LOGIC_VECTOR(1 downto 0);
    rd_data: in STD_LOGIC_VECTOR(63 downto 0);
    -----------------------------------------------
	alu_output: out STD_LOGIC_VECTOR(63 downto 0));
end component;

component DataForwarding is
port(
IFIDrs1, IFIDrs2, IFIDrs3, IDEXrd : in std_logic_vector(4 downto 0);
forward1, forward2, forward3 : out std_logic;
writeReg : in std_logic);
end component;

signal instruction_sig : std_logic_vector(23 downto 0);
signal controlOut_sig : std_logic_vector(8 downto 0);
signal r1Out_sig, r2Out_sig, r3Out_sig, writeRegOut_sig : std_logic_vector(4 downto 0);
signal immediateOut_sig : std_logic_vector(15 downto 0);
signal liLocation_sig, aluControl_sig, MAMS_sig : std_logic_vector(1 downto 0);
signal regWrite_sig : std_logic;
signal opcode_sig : std_logic_vector(6 downto 0);
signal out1_sig, out2_sig, out3_sig, rdDataOut_sig : std_logic_vector(63 downto 0);
signal aluControlOut_sig, MAMSOut_sig, liLocationOut_sig : std_logic_vector(1 downto 0);

signal opCodeOut_sig : std_logic_vector(6 downto 0);
signal immediateOut_sig1 : std_logic_vector(15 downto 0);
signal r1Out_sig1, r2Out_sig1, r3Out_sig1, rdDataOut_sig1 : std_logic_vector(63 downto 0);
signal regWriteOut_sig : std_logic;
signal writeRegNumOut_sig : std_logic_vector(4 downto 0);
signal aluOut_sig : std_logic_vector(63 downto 0);
signal forward1_sig, forward2_sig, forward3_sig : std_logic;

begin

FIB : FullInstructionBuffer port map(initialAddress, clock, reset, instruction_sig);

IFIDBuffer : IfId port map(instruction_sig, controlOut_sig, r1Out_sig, r2Out_sig, r3Out_sig, writeRegOut_sig, immediateOut_sig, clock);

ctrl : Control port map(controlOut_sig,liLocation_sig, aluControl_sig, MAMS_sig, regWrite_sig, opcode_sig);

rFile : RegisterFile port map(regWrite_sig, r1Out_sig, r2Out_sig, r3Out_sig, writeRegOut_sig, aluOut_sig, out1_sig, out2_sig, out3_sig, rdDataOut_sig);

IDEXBuffer : IdEx port map(clock, aluControl_sig, MAMS_sig, opcode_sig, regWrite_sig, writeRegOut_sig, out1_sig, out2_sig, out3_sig, rdDataOut_sig, immediateOut_sig, liLocation_sig, forward1_sig, forward2_sig, forward3_sig, aluOut_sig, aluControlOut_sig, MAMSOut_sig, opCodeOut_sig, regWriteOut_sig, r1Out_sig1, r2Out_sig1, r3Out_sig1, rdDataOut_sig1, writeRegNumOut_sig, immediateOut_sig1, liLocationOut_sig);

df : DataForwarding port map(r1Out_sig, r2Out_sig, r3Out_sig, writeRegNumOut_sig, forward1_sig, forward2_sig, forward3_sig, regWriteOut_sig);

ALUMOD : alu port map(opCodeOut_sig, r1Out_sig1, r2Out_sig1, r3Out_sig1, aluControlOut_sig, MAMSOut_sig, immediateOut_sig1, liLocationOut_sig, rdDataOut_sig1, aluOut_sig);

instruction <= instruction_sig; 
controlOut <= controlOut_sig;
r1Out <= r1Out_sig;
r2Out <= r2Out_sig;
r3Out <= r3Out_sig;
writeRegOut <= writeRegOut_sig;
immediateOut <= immediateOut_sig;
aluControlOut <= aluControlOut_sig;
MAMSOut <= MAMSOut_sig;
opCodeOut <= opCodeOut_sig; 
regWriteOut <= regWriteOut_sig;
r1Outd <= r1Out_sig1;
r2Outd <= r2Out_sig1;
r3Outd <= r3Out_sig1;
writeRegOutd <= rdDataOut_sig1;
writeRegNumOut <= writeRegNumOut_sig;
immediateOut1 <= immediateOut_sig1;
liLocationOut <= liLocationOut_sig;
aluOut <= aluOut_sig;
forward1 <= forward1_sig;
forward2 <= forward2_sig;
forward3 <= forward3_sig;
end structural;