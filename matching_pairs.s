; contains all the components instead of including them like a sane person would do
		B main

bSIPrompt DEFB "Enter coordinates.\n",0
error DEFB "Error occured while processing input. Try again.\n",0
gz DEFB "You found a match! Well done.\n",0
seed    DEFW    0x1234567
complete DEFW 0
board	DEFW 	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 
;board	DEFW 	3, 1, 4, 7, 5, 1, 7, 6, 6, 0, 2, 5, 0, 4, 2, 3
verticalHeader DEFB     "B", "C", "D", 3
multiplier DEFW 65539
unknown DEFB "*",0
space DEFB " ",0
horizontalHeader DEFB "       1    2    3    4\n  A  ",0
newline DEFB " \n",0
doubleSpace DEFB "  ",0
gap DEFB "     ",0
victory DEFB "Victory!\n",0

;overuse of registers here without using the stack. this was due to time constraints leading to an inability to change such a volume of code without missing the deadline.
        ALIGN
main    MOV R13,#0x100000     ; Setup stack (see Lecture 21)
        MOV R5,#0       ;r5 contains the number of revealed cells
        ADRL R0,board
        BL generateBoard        ;by now the board is filled with random values. use bSI to edit what R1 and R2 are
game    BL boardSquareInput     ;r0 now contains the cell number the user has chosen
        MOV R5,R0       ;r5 is a cell we want to reveal
        BL boardSquareInput
        MOV R6,R0       ;r6 is the other cell to reveal
        MOV R1,R5
        MOV R2,R6       ;we can use r5 and r6 here
        BL cls
        ADRL R5,board
        LDRB R6,[R5,R1 LSL #2]
        LDRB R8,[R5,R2 LSL #2] ;we can also use r11 i think
        SUB R11,R6,R8
        CMP R11,#0
        MOV R0,R11
        BNE skipCull
        MOV R11,#0xff
        STRB R11,[R5,R1 LSL #2]
        STRB R11,[R5,R2 LSL #2]
        LDRB R0,complete
        ADD R0,R0,#2
        CMP R0,#16
        BNE skipFin
        MOV R11,R0
        ADR R0,victory
        SWI 3
        SWI 2
        MOV R0,R11
skipFin STRB R0,complete
        ADRL R0,gz
        SWI 3
        BL cls
skipCull        BL printMaskedBoard     ;r8 contains cell - other cell. so if its 0, then the cells match
        CMP R0,#0
        BNE game
        SWI 2

; cls -- Clears the Screen
; Input : None
; Ouptut: None
cls     MOV R0,#10
        MOV R8,#100
cls_loop        SWI 0
        SUB R8,R8,#1
        CMP R8,#0
        BGT cls_loop
        MOV PC,R14

; boardSquareInput -- read the square to reveael from the Keyboard
; Input:  R0 <- address of prompt for user
; Output: R0 <- Array index of entered square

boardSquareInput        ADRL R0,bSIPrompt
        SWI 3   ;prompt user to enter coordinates
input   SWI 1   ;take value character in r0
        CMP R0,#65
        BLT fail
        CMP R0,#68
        BLE validUpper     ;we know its upper case
        CMP R0,#97
        BLT fail
        CMP R0,#100
        BLE validLower      ;we know its lower case
validUpper      SUB R1,R0,#65   ;65 instead of 64 because we want to be between 0-3 not 1-4
        B checkSecond
validLower      SUB R1,R0,#97    ;97 instead of 96 because we want to be between 0-3 not 1-4
        B checkSecond
checkSecond     SWI 1   ;we've stored the first character in a better format in R1, now to do the same for the second character in R2
        CMP R0,#48
        BLE fail
        CMP R0,#52
        BGT fail
        SUB R2,R0,#49
        B convertInput
convertInput    MOV R3,#4
        MLA R0,R1,R3,R2 ;r0 = (r1 * r3) + R2 so between 0 and 15
        MOV PC,R14

fail    ADRL R0,error
        SWI 3
        B main


; generateBoard
; Input R0 -- array to generate board in
;r0 is a pointer to the array we want to edit. can use any other register
generateBoard        MOV R1,R0       ;r1 now contains pointer to array
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
        STRB R5,[R1,R0]
        MOV R14,R4
        ADD R6,R6,#1
        CMP R6,#2
        BLT continueGen
        MOV R6,#0
        ADD R5,R5,#1
        CMP R5,#8
        BLT continueGen
        MOV PC,R14

; randu -- Generates a random number
; Input: None
; Ouptut: R0 -> Random number
randu   LDR R3,multiplier
        MOV R2,#2147483647
        LDR R0,seed
        MUL R0,R0,R3
        AND R0,R0,R2
        STR R0,seed
        MOV PC,R14

; printMaskedBoard -- print the board with only the squares in R1 and R2 visible
; Input: R0 <-- Address of board
;        R1 <-- Number of Cell to reveal
;        R2 <-- Number of Cell to reveal
printMaskedBoard      MOV R6,R1
        MOV R7,R2
        MOV R1,R0       ;r6 and r7 = cells to reveal, r1 = address of board
        ADRL R0,horizontalHeader
        SWI 3   ;print out horizontal header
        MOV R2,#0
        MOV R3,#0
        MOV R8,#0
        MOV R5,#0       ;empty r2,r3, r8 and r5. they havent been used yet
continuePrint   MOV R4,R14      ; store r14 in r4
        ADRL R1,board   ;store address of board in r1 again
        ADRL R0,doubleSpace     ;print somes spaces out
        SWI 3   ;print
        LDRB R0,[R1,R2] ;r0 = load from address [r1 + r2]
        BL convertLetter
        MOV R14,R4      ;pc management
        SWI 0   ;print out the char in r0
        ADRL R0,doubleSpace     ;put some spaces in r0
        SWI 3   ;print those spaces out
        ADD R2,R2,#4    ;r2 += 4
        ADD R3,R3,#1    ;r3++
        CMP R3,#4       ;r3 == 4
        BLGE nextRow    ;if r3 >=4 then go to next row
        MOV R14,R4      ;pc management
        CMP R2,#60      ;r2 == 60
        BLE continuePrint       ;if r2 <= 60 then continue printing
        MOV PC,R14      ;return to call source

;r0 has a number between 0 and 7. convert to a letter between A and H
;65 = H, 72 = H
;r6 and r7 contain the positions we need to reveal. for any other position, we just print asterisk
;multiply r6 and r7 by 4 so we can compare them to R2, move them to r8 and r9 respectively first
convertLetter   CMP R0,#0xff
        BEQ convertSpace
        MOV R12,#0      ;r12 = 0
        MOV R11,R14     ;r11 = r14 (pc management)
        MOV R8,R6       ;r8 = r6 (cell to reveal)
        MOV R9,R7       ;r9 = r7 (cell to reveal)
        MOV R10,#4      ;r10 = 4
        MUL R8,R8,R10   ;r8 *= 4
        MUL R9,R9,R10   ;r9 *= 4
        CMP R8,R2       ;r8 == r2
        BLNE notOne     ;if r8 != r2, then go to notOne(r2 is an iterator for all the cells)
        MOV R14,R11     ;pc management
        CMP R9,R2       ;r9 == r2
        BLNE notOne     ;if r9 != r2, then go to notOne(r2 is an iterator fro all the cells)
        MOV R14,R11     ;pc management
        ADD R0,R0,#65   ;r0 += 65 (convert to ascii if we want to reveal it as a letter)
        MOV PC,R14      ;return to call source
notOne  ADD R12,R12,#1  ;r12++. notOne is a subsystem which is executed when we know that its not a matching cell
MOV R13,R14     ;r13 = r14 (pc management)
CMP R12,#2      ;r12 == 2
BLGE convertUnknown     ;if r12 >= 2, then convert to unknown. this is because we want to do it only if its NEITHER of the cells we want to print out
MOV R14,R13     ;pc management
MOV PC,R14      ;return to call source

convertSpace    ADRL R0,space
        SWI 3
        MOV PC,R14

convertUnknown  CMP R0,#0xff
BEQ convertSpace
ADRL R0,unknown
SWI 3
MOV PC,R14

nextRow ADRL R0,newline
SWI 3
MOV R3,#0
ADRL R1,verticalHeader
ADRL R0,doubleSpace
SWI 3
CMP R5,#3
BGE break
LDRB R0,[R1,R5]
SWI 0
ADD R5,R5,#1
ADRL R0,doubleSpace
SWI 3
break   MOV PC,R14
