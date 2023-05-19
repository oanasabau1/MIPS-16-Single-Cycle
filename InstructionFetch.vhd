library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionFetch is
Port (clk: in STD_LOGIC;
      rst : in STD_LOGIC;
      en : in STD_LOGIC;
      BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
      JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
      Jump : in STD_LOGIC;
      PCSrc : in STD_LOGIC;
      Instruction : out STD_LOGIC_VECTOR(15 downto 0);
      PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end InstructionFetch;

architecture Behavioral of InstructionFetch is

type tROM is array (0 to 255) of STD_LOGIC_VECTOR (15 downto 0);
signal ROM: tROM := (

B"010_000_001_0000001", -- X"4081" -- lw $1, 1($0) --0
B"010_000_010_0000101", --X"4105" -- lw $2, 5($0) --1
B"100_010_001_0000110", --X"8886" -- beq $1, $2, 6 --2
B"000_001_010_011_0_111", --X"0537" -- slt $3, $1, $2 --3
B"100_000_011_0000010", --X"8182" -- beq $3, $0, 2 --4
B"000_010_001_010_0_001", --X"08A1" -- sub $2, $2, $1 --5
B"111_0000000000010", --X"E002" -- j 2 --6
B"000_001_010_001_0_001", --X"0511" -- sub $1, $1, $2 --7
B"111_0000000000010", --X"E002" -- j 2 --8
B"011_000_001_0000111", --X"6087" --sw $1, 7($0) --9
others => X"0000" --NoOp (ADD $0, $0, $0) --10
);

signal PC : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal PCAux, NextAddr, AuxSgn, AuxSgn1: STD_LOGIC_VECTOR(15 downto 0);

begin

ProgramCounter:process(clk)
begin
if rising_edge(clk) then
if rst = '1' then
PC <= (others => '0');
elsif en = '1' then
PC <= NextAddr;
end if;
end if;
end process;

MUXBranch:process(PCSrc, PCAux, BranchAddress)
begin
case PCSrc is 
   when '1' => AuxSgn <= BranchAddress;
   when others => AuxSgn <= PCAux;
end case;
end process;	

MUXJump:process(Jump, AuxSgn, JumpAddress)
begin
case Jump is
   when '1' => NextAddr <= JumpAddress;
   when others => NextAddr <= AuxSgn;
end case;
end process;

Instruction <= ROM(conv_integer(PC(7 downto 0)));
PCAux <= PC + 1;
PCinc <= PCAux;

end Behavioral;