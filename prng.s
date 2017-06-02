    B clearRegisters

randS DEFB "\nThe next random number is ",0
seed DEFW 5
multiplier DEFW 65539

    ALIGN 

clearRegisters  MOV R0,#0
MOV R1,R0
MOV R2,R1
B begin

begin BL randu 
MOV R1,R0 
ADR R0,randS 
SWI 3 
MOV R0,R1 
SWI 4 
SWI 2 

randu   LDR R3,multiplier
MOV R2,#2147483647
LDR R0,seed
MUL R0,R0,R3
AND R0,R0,R2
STR R0,seed
MOV PC,R14