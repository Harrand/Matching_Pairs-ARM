B clearRegisters
prompt DEFB "\nPlease enter a number between 0 and 255\n",0
result DEFB "\nYou typed the integer: ",0
outrange DEFB "\nThe value you typed is out of range, it must be between 0 and 255! Try again...",0
toobig DEFB ", which is higher than the number!",0
toolittle DEFB ", which is lower than the number!",0
correctmsg DEFB ", which is equal to the number. You win, well done!",0
error DEFB "\nUnexpected error occured, resetting registers. Try again:\n",0
randS DEFB "\nThe next random number is ",0
seed DEFW 500
multiplier DEFW 65539

    ALIGN
clearRegisters MOV R0,#0
MOV R1,R0
MOV R2,R1
MOV R3,R2
B begin

;when resetting, the rand number changes, dont do this

begin   BL randu ; r0 now contains a random number
BL modifyRand   ; r3 now contains a random number between 0-255
B beginRead

beginRead    MOV R0,#0
MOV R1,#0
MOV R2,#0
ADR R0,prompt ; begin the reading section
BL readInt 
MOV R1,R0 ; r1 now contains the input decimal
B checkRange

checkRange  CMP R1,#0
BGE greater
B outofrange
greater CMP R1,#255
BLE inRange
B outofrange

outofrange  ADRL R0,outrange
SWI 3
B beginRead

;by now, r3 contains the rand, and r1 contains the input
inRange ADRL R0,result
SWI 3
MOV R0,R1
SWI 4
CMP R1,R3
BGT tooLarge
BLT tooSmall
BEQ correct

tooLarge    ADRL R0,toobig
SWI 3
B beginRead

tooSmall    ADRL R0,toolittle
SWI 3
B beginRead

correct ADRL R0,correctmsg
SWI 3
SWI 2

randu   LDR R3,multiplier
MOV R2,#2147483647
LDR R0,seed
MUL R0,R0,R3
AND R0,R0,R2
STR R0,seed
MOV PC,R14

modifyRand  MOV R0, R0 ASR #8   ;shift R0 right by 8 bits
AND R0,R0,#0xff ; take the modulo by 256
MOV R3,R0   ; random number between 0-255 is stored in R3
MOV PC,R14 

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

fail    ADRL R0,error
SWI 3
B beginRead

finish
MOV R0,R1
MOV PC,R14