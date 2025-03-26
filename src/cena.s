.text

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
    
; nseed -> R0 e R1
; seed_addr -> R4
srand:
    PUSH R4
    LDR R4, seed_addr
    STR R0, [R4]
    STR R1, [R4, #2]
    POP R4
    MOV PC, LR

rand:
    PUSH LR
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    ; seed atual (32 bits) -> R0 e R1
    LDR R4, seed_addr
    LDR R0, [R4]    ; Parte inferior
    LDR R1, [R4, #2]    ; Parte superior

    ; prepara para umull32: seed * 214013
    ; 214013 = 0x000343FD (32 bits)
    MOV R2, #0x43FD   ; Parte inferior
    MOV R3, #0x0003   ; Parte superior
    BL umull32  ; seed * 214013

    ; adiciona 2531011 (0x00269EC3) ao resultado
    ; para 64 bits, é preciso carry
    ADD R0, R0, #0x9EC3     ; + parte inferior
    ADC R1, R1, #0x0026     ; + parte superior com carry

    ; atualiza seed
    LDR R4, seed_addr
    STR R0, [R4]    ; Parte inferior
    STR R1, [R4, #2]    ; Parte superior

    ; retorna o resultado (seed >> 16)
    MOV R0, R1      ; retorna os 16 bits superiores

    POP R4
    POP R3
    POP R2
    POP R1

    ADD SP, SP, #2  ; SP += 2 (para pular o LR)
    POP PC          ; retorna

seed_addr:
    .word seed

.data

N:  
    .word 5

result: 
    .word 17747
    .word 2055
    .word 3664
    .word 15611
    .word 9816

seed:
    .word 1     ; LSB
    .word 0     ; MSB
    
/*
214013:
    .word 0x43FD    ; Parte inferior
    .word 0x0003    ; Parte superior
*/
/*
2531011:
    .word 0x9EC3    ; Parte inferior
    .word 0x0026    ; Parte superior
*/
; verificar RAND_MAX para 32 bits (0xFFFFFFFF), como fica?