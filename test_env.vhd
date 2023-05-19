library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
 Port (clk : in STD_LOGIC;
       btn : in STD_LOGIC_VECTOR (4 downto 0); 
       sw : in STD_LOGIC_VECTOR (15 downto 0);
       led : out STD_LOGIC_VECTOR (15 downto 0);
       an : out STD_LOGIC_VECTOR (3 downto 0);
       cat : out STD_LOGIC_VECTOR (6 downto 0));  
end test_env;

architecture Behavioral of test_env is

component MPG is 
Port (clk : in STD_LOGIC;
      btn : in STD_LOGIC;
      en : out STD_LOGIC);
end component MPG;

component InstructionFetch is
Port (clk: in STD_LOGIC;
      rst : in STD_LOGIC;
      en : in STD_LOGIC;
      BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
      JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
      Jump : in STD_LOGIC;
      PCSrc : in STD_LOGIC;
      Instruction : out STD_LOGIC_VECTOR(15 downto 0);
      PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end component InstructionFetch;

component InstructionDecode is
 Port (clk: in STD_LOGIC;
      en: in STD_LOGIC;
      Instr: in STD_LOGIC_VECTOR(12 downto 0);
      WD: in STD_LOGIC_VECTOR(15 downto 0);
      RegWrite: in STD_LOGIC;
      RegDst: in STD_LOGIC;
      ExtOp: in STD_LOGIC;
      RD1: out STD_LOGIC_VECTOR(15 downto 0);
      RD2: out STD_LOGIC_VECTOR(15 downto 0);
      Ext_Imm: out STD_LOGIC_VECTOR(15 downto 0);
      func: out STD_LOGIC_VECTOR(2 downto 0);
      sa: out STD_LOGIC);
end component InstructionDecode;

component MainControl is
Port (Instr : in STD_LOGIC_VECTOR(2 downto 0);
      RegDst : out STD_LOGIC;
      ExtOp : out STD_LOGIC;
      ALUSrc : out STD_LOGIC;
      Branch : out STD_LOGIC;
      Jump : out STD_LOGIC;
      ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
      MemWrite : out STD_LOGIC;
      MemtoReg : out STD_LOGIC;
      RegWrite : out STD_LOGIC);
end component MainControl;

component ExecutionUnit is
Port (PCinc : in STD_LOGIC_VECTOR(15 downto 0);
      RD1 : in STD_LOGIC_VECTOR(15 downto 0);
      RD2 : in STD_LOGIC_VECTOR(15 downto 0);
      Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
      func : in STD_LOGIC_VECTOR(2 downto 0);
      sa : in STD_LOGIC;
      ALUSrc : in STD_LOGIC;
      ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
      BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
      ALURes : out STD_LOGIC_VECTOR(15 downto 0);
      Zero : out STD_LOGIC);
end component ExecutionUnit;

component MEM is
port (clk : in STD_LOGIC;
      en : in STD_LOGIC;
      ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
      RD2 : in STD_LOGIC_VECTOR(15 downto 0);
      MemWrite : in STD_LOGIC;			
      MemData : out STD_LOGIC_VECTOR(15 downto 0);
      ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component MEM;

component SSD is
Port (clk : in STD_LOGIC;
      digits : in STD_LOGIC_VECTOR (15 downto 0);
      cat : out STD_LOGIC_VECTOR (6 downto 0);
      an : out STD_LOGIC_VECTOR (3 downto 0));
end component SSD;

signal Instruction, PCinc, RD1, RD2, WD, Ext_imm, Ext_func, Ext_sa : STD_LOGIC_VECTOR(15 downto 0);
signal JumpAddress, BranchAddress, ALURes, ALUres1, MemData: STD_LOGIC_VECTOR(15 downto 0);
signal func : STD_LOGIC_VECTOR(2 downto 0);
signal sa, zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(15 downto 0);
signal en, rst, PCSrc : STD_LOGIC;
--main controls
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);

begin

--buttons: reset, enable
monopulse1: MPG port map(clk=>clk, btn=>btn(0), en=>en);
monopulse2: MPG port map(clk=>clk, btn=>btn(1), en=>rst);

--main unit
instr_fetch: InstructionFetch port map(clk=>clk, rst=>rst, en=>en, BranchAddress=>BranchAddress, JumpAddress=>JumpAddress, 
                                       Jump=>Jump, PCSrc=>PCSrc, Instruction=>Instruction, PCinc=>Pcinc);
instr_decode: InstructionDecode port map(clk=>clk, en=>en, Instr=>Instruction(12 downto 0), WD=>WD,
                                         RegWrite=>RegWrite, RegDst=>RegDst, ExtOp=>ExtOp, RD1=>RD1, RD2=>RD2,
                                         Ext_imm=>Ext_imm, func=>func, sa=>sa);
instr_mainControl: MainControl port map(Instr=>Instruction(15 downto 13), RegDst=>RegDst, ExtOp=>ExtOp, ALUSrc=>ALUSrc,
                                        Branch=>Branch, Jump=>Jump, ALUOp=>ALUOp,
                                        MemWrite=>MemWrite, MemtoReg=>MemtoReg, RegWrite=>RegWrite);
instr_execute: ExecutionUnit port map(PCinc=>PCinc, RD1=>RD1, RD2=>RD2, Ext_imm=>Ext_imm, func=>func, sa=>sa, ALUSrc=>ALUSrc, 
                                      ALUOp=>ALUOp, BranchAddress=>BranchAddress, ALURes=>ALURes, Zero=>Zero);
instr_MEM: MEM port map(clk=>clk, en=>en, ALUResIn=>ALURes, RD2=>RD2, MemWrite=>MemWrite, MemData=>MemData, ALUResOut=>ALURes);
                                      
--branch control
PCSrc <= Zero and Branch;

--jump address
JumpAddress <= PCinc(15 downto 13) & Instruction(12 downto 0);
      
--WriteBack unit 
with MemtoReg select 
WD <= MemData when '1',
ALURes when '0',
(others=>'X') when others;
                                       
--SSD display MUX
with sw(7 downto 5) select
digits <= Instruction when "000",
          PCinc when "001",
          RD1 when "010",
          RD2 when "011",
          Ext_Imm when "100",
          ALURes when "101",
          MemData when "110",
          WD when "111",
          (others => 'X') when others;
    
display: SSD port map(clk=>clk, digits=>digits, an=>an, cat=>cat);

--main controls on the leds
led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;