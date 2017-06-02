        B main

; each element separated by 4 bits
board	DEFW 	3, 1, 4, 7, 5, 1, 7, 6, 6, 0, 2, 5, 0, 4, 2, 3
verticalHeader DEFB     "B", "C", "D", 3
horizontalHeader DEFB "       1    2    3    4\n  A  ",0
newline DEFB " \n",0
doubleSpace DEFB "  ",0
gap DEFB "     ",0

        ALIGN
main    ADR R0, board 
        BL printBoard
        SWI 2

;r2 serves as a 4 incrementer. r3 increases by 1 instead
printBoard     MOV R1,R0
        ADR R0,horizontalHeader
        SWI 3
        MOV R2,#0
        MOV R3,#0
        MOV R5,#0
continuePrint   MOV R4,R14
        ADR R1,board
        ADR R0,doubleSpace
        SWI 3
        LDRB R0,[R1,R2]
        BL convertLetter
        MOV R14,R4
        SWI 0
        ADR R0,doubleSpace
        SWI 3
        ADD R2,R2,#4
        ADD R3,R3,#1
        CMP R3,#4
        BLGE nextRow
        MOV R14,R4
        CMP R2,#60
        BLE continuePrint
        MOV PC,R14

;r0 has a number between 0 and 7. convert to a letter between A and H
;65 = H, 72 = H
convertLetter   ADD R0,R0,#65
        MOV PC,R14

nextRow ADR R0,newline
SWI 3
MOV R3,#0
ADR R1,verticalHeader
ADR R0,doubleSpace
SWI 3
CMP R5,#3
BGE break
LDRB R0,[R1,R5]
SWI 0
ADD R5,R5,#1
ADR R0,doubleSpace
SWI 3
break   MOV PC,R14
