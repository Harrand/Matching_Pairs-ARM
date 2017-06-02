        B main

board	DEFW 	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 
seed DEFW 500
multiplier DEFW 65539
verticalHeader DEFB     "B", "C", "D", 3
horizontalHeader DEFB "       1    2    3    4\n  A  ",0
newline DEFB " \n",0
doubleSpace DEFB "  ",0
gap DEFB "     ",0

        ALIGN
main    ADR R0, board 

        BL genBoard

        ADR R0, board 
        BL printBoard
        SWI 2

randu   LDR R3,multiplier
        MOV R2,#2147483647
        LDR R0,seed
        MUL R0,R0,R3
        AND R0,R0,R2
        STR R0,seed
        MOV PC,R14

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

;r0 is a pointer to the array we want to edit. can use any other register
genBoard        MOV R1,R0       ;r1 now contains pointer to array
        MOV R5,#0
        MOV R6,#0
        MOV R7,#4
continueGen     MOV R4,R14
        BL randu        ;r0 now contains a random num between 0 and 2^31
        MOV R14,R4
        MOV R0, R0 ASR #8 ; shift R0 right by 8 bits 
        AND R0, R0, #0xf  ; take the modulo by 16, r0 is now a random num between 0 and 15
        MUL R0,R0,R7
        LDRB R3,[R1,R0]
        CMP R3,#0xff
        BNE continueGen
        STR R5,[R1,R0]
        MOV R14,R4
        ADD R6,R6,#1
        CMP R6,#2
        BLT continueGen
        MOV R6,#0
        ADD R5,R5,#1
        CMP R5,#8
        BLT continueGen
        MOV PC,R14

