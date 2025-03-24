B main

if:
    MOV R6, #0
    CMP R6, R10
    BNE end_else_if
    CMP R6, R9
    BNE end_else_if
    MOV R6, #1
    CMP R4, R6
    BNE end_else_if

    ADD R7, R1, R7

    B end_if

end_if:
    MOV R6, LR
    ADD PC, R6, #2

else_if:
    MOV R6, #1
    CMP R6, R10
    BNE end_else_if
    MOV R6, #0
    CMP R6, R9
    BNE end_else_if
    CMP R4, R6
    BNE end_else_if

    MOV R6, R7
    SUB R7, R6, R1
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
    ; R9 é sempre zero lol
    MOV R9, #0
    MOV R6, #1
    AND R10, R6, R8
    BL if
    BL else_if
    ADD R5, R5, #1

    ; p_1 = result&1
    MOV R6, #1
    AND R4, R6, R8

    ; result = result >> 1
    MOV R6, R8
    ASR R7, R7, #1
    BCS while_extra
    LSR R8, R6, #1

    B while

while_extra:
    MOV R6, R8
    LSR R8, R6, #1
    MOV R6, #1
    LSL R6, R6, #15
    ADD R8, R6, R8
    B while

while_end:
    POP PC

umull32:
    PUSH LR
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    ; -------- IN --------
    ; R0, R1 => M
    ; R2, R3 => m
    ;
    ; ----- INTERNAL -----
    ; R4 => P_1
    ; R5 => i
    ; R6 => TEMP
    ; R7 => Result [<]
    ; R8 => Result [>]
    ; R9 => AND [<]
    ; R10 => AND [>]

    MOV R4, #0 ; Cria p_1 = 0
    MOV R5, #0 ; i
    MOV R6, #1 ; Literal 1 ou 0 para operações
    MOV R7, R2 ; Lado Esquerdo do Resultado
    MOV R8, R3 ; Lado Direito do Resultado

    BL while_begin

    MOV R0, R7
    MOV R1, R8
    
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP PC

main:
    MOV R0, #0
    MOV R1, #9
    MOV R2, #0
    MOV R3, #9
    BL umull32
    