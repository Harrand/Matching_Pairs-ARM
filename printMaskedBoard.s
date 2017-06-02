        B main
; each element separated by 4 bits
board	DEFW 	3, 1, 4, 7, 5, 1, 7, 6, 6, 0, 2, 5, 0, 4, 2, 3
verticalHeader DEFB     "B", "C", "D", 3
unknown DEFB "*",0
horizontalHeader DEFB "       1    2    3    4\n  A  ",0
newline DEFB " \n",0
doubleSpace DEFB "  ",0
gap DEFB "     ",0

        ALIGN
main    ADR R0, board
        MOV R1,#2
        MOV R2,#15
        BL printMaskedBoard
        SWI 2

;r2 serves as a 4 incrementer. r3 increases by 1 instead
printMaskedBoard      MOV R6,R1
        MOV R7,R2
        MOV R1,R0
        ADR R0,horizontalHeader
        SWI 3
        MOV R2,#0
        MOV R3,#0
        MOV R5,#0
continuePrint   MOV R4,R14
        ADR R1,board
        ADRL R0,doubleSpace
        SWI 3
        LDRB R0,[R1,R2]
        BL convertLetter
        MOV R14,R4
        SWI 0
        ADRL R0,doubleSpace
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
;r6 and r7 contain the positions we need to reveal. for any other position, we just print asterisk
;multiply r6 and r7 by 4 so we can compare them to R2, move them to r8 and r9 respectively first
convertLetter   MOV R12,#0
        MOV R11,R14
        MOV R8,R6
        MOV R9,R7
        MOV R10,#4
        MUL R8,R8,R10
        MUL R9,R9,R10
        CMP R8,R2
        BLNE notOne
        MOV R14,R11
        CMP R9,R2
        BLNE notOne
        MOV R14,R11
        ADD R0,R0,#65
        MOV PC,R14

notOne  ADD R12,R12,#1
MOV R13,R14
CMP R12,#2
BLGE convertUnknown
MOV R14,R13
MOV PC,R14

convertUnknown  ADR R0,unknown
SWI 3
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
ADRL R0,doubleSpace
SWI 3
break   MOV PC,R14
