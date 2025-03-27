B main
    
umull32_if:
    ;   \/ R7 for comparison with 0
    MOV R7, #0

    ; Compare R5&1 == 0
    MOV R8, #1
    AND R8, R5, R8 ; R5 and 1 => R8
    CMP R7, R8 ; R5 and 1 == 0
    BNE umull32_else_if
    
    ; Compare R4&1 == 0
    MOV R8, #1
    AND R8, R4, R8 ; R4 and 1 => R8
    CMP R7, R8 ; R4 and 1 == 0
    BNE umull32_else_if

    ; Compare R3&1 == 0
    MOV R8, #1
    AND R8, R3, R8 ; R3 and 1 => R8
    CMP R7, R8 ; R3 and 1 == 0
    BNE umull32_else_if

    ; Compare R2&1 == 0
    MOV R8, #1
    AND R8, R2, R8 ; R2 and 1 => R8
    CMP R7, R8 ; R2 and 1 == 0
    BNE umull32_else_if

    ; Compare p_1 == 1
    MOV R8, #1
    CMP R6, R8 ; R6 == 1
    BNE umull32_else_if

    ADD R3, R1, R3
    ADC R2, R0, R2

    B umull32_end_if

umull32_else_if:
    ;   \/ R7 for comparison with 1
    MOV R7, #1
    
    ; Compare R5&1 == 1
    MOV R8, #1
    AND R8, R5, R8 ; R5 and 1 => R8
    CMP R7, R8 ; R5 and 1 == 1
    BNE umull32_end_if

    ; Compare p_1 == 0
    MOV R8, #0
    CMP R6, R8 ; R6 == 0
    BNE umull32_end_if

    SUB R2, R2, R0
    SBC R3, R3, R1

umull32_end_if:
    MOV PC, LR

umull32_while_begin:
    MOV R7, #0 ; i = 0
    PUSH LR

umull32_while:
    MOV R8, #32
    CMP R7, R8
    BEQ umull32_while_end

    PUSH R7 ; Usar o índice como complemento à variável temporária.
    BL umull32_if
    POP R7

    ; p_1 = result&1
    MOV R8, #1
    AND R6, R5, R8

    ; result = result >> 1
    lSR R2, R2, #1
    RRX R3, R3
    RRX R4, R4
    RRX R5, R5

    ADD R7, R7, #1 ; Incremento (i++)
    B umull32_while

umull32_while_end:
    POP PC

umull32:
    PUSH LR
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    ; -------- IN --------
    ; R0, R1 => M
    ; R2, R3 => m
    ;
    ; ------- OUT -------
    ; R0, R1, R2, R3 => p
    ;
    ; ----- INTERNAL -----
    ; R2, R3, R4, R5 => Resultado
    ; R6 => p_1
    ; R7 => i/TEMP
    
    MOV R5, R3
    MOV R4, R2
    MOV R3, #0
    MOV R2, #0

    MOV R6, #0 ; p_1 = 0

    BL umull32_while_begin

    MOV R0, R2
    MOV R1, R3
    MOV R2, R4
    MOV R3, R5
    
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP PC

main:
    MOV R0, #0
    MOV R1, #2
    MOV R2, #0
    MOV R3, #2
    BL umull32
    b .
