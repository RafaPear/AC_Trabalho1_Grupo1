B main

if:
    MOV R5, #0
    CMP R5, R6
    BNE end_else_if
    MOV R5, #1
    CMP R4, R5
    BNE end_else_if

    ADD R2, R1, R2

    B end_if

end_if:
    MOV R5, LR
    ADD PC, R5, #2

else_if:
    MOV R5, #1
    CMP R5, R6
    BNE end_else_if
    MOV R5, #0
    CMP R4, R5
    BNE end_else_if

    SUB R2, R2, R1
    B end_else_if

end_else_if:
    MOV PC, LR

while_begin:
    PUSH LR
    B while

while:
    MOV R6, #16
    CMP R5, R6
    BEQ while_end
    
    PUSH R5
    
    MOV R5, #1
    AND R6, R5, R3
    
    BL if
    BL else_if
    ; p_1 = result&1
    MOV R5, #1
    AND R4, R5, R3

    POP R5

    ADD R5, R5, #1
    ; result = result >> 1
    ASR R2, R2, #1
    RRX R3, R3
    B while


while_end:
    POP PC

umull32:
    PUSH LR
    PUSH R4
    PUSH R5
    PUSH R6
    ; -------- IN --------
    ; R0, R1 => M
    ; R2, R3 => m
    ;
    ; ----- INTERNAL -----
    ; R4 => P_1
    ; R5 => i/TEMP
    ; R6 => AND [>]
    
    MOV R4, #0 ; p_1 = 0
    MOV R5, #0 ; i = 0

    BL while_begin

    MOV R0, R2
    MOV R1, R3
    
    POP R6
    POP R5
    POP R4
    POP PC

main:
    MOV R0, #0
    MOV R1, #50
    MOV R2, #0
    MOV R3, #50
    BL umull32
    