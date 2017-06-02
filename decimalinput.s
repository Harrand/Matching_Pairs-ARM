B clearRegisters
prompt DEFB "\nPlease enter a number.\n",0
result DEFB "\nYou typed the integer: ",0
error DEFB "\nUnexpected error occured, resetting registers. Try again:\n",0

    ALIGN
clearRegisters MOV R0,#0
MOV R1,R0
MOV R2,R1
B begin 


begin   ADR R0,prompt 
BL readInt 
MOV R1,R0 
ADR R0,result 
SWI 3 
MOV R0,R1 
SWI 4 
SWI 2 

readInt    SWI 3
B input

input   SWI 1 ; take value character in r0
CMP R0,#48
BGE greaterThan
B invalid
greaterThan     CMP R0,#57
BLE valid
B invalid

valid   SUB R0,R0,#48 ; convert ascii value to actual integer
SWI 4
MOV R2,#10
MLA R1,R1,R2,R0 ; r1 *= 10, r1 += r0; so decimal shift left 1 and add the next r0
B input

invalid     CMP R0,#10
BEQ finish ; go to finish if enter was inputted
B fail

fail    ADR R0,error
SWI 3
B clearRegisters

finish
MOV R0,R1
MOV PC,R14