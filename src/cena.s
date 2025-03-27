.text

B main

; nseed -> R0 e R1
; seed_addr -> R4
srand:
    PUSH R4
    LDR R4, seed_addr
    STR R0, [R4]
    STR R1, [R4, #4]
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
    LDR R1, [R4, #4]    ; Parte superior

    ; prepara para umull32: seed * 214013
    ; 214013 = 0x000343FD (32 bits)
    MOV R2, #0xFD   ; Parte inferior
    MOVT R2, #0x43  ; Parte superior
    MOV R3, #0x03   ; Parte inferior
    BL umull32  ; seed * 214013

    ; adiciona 2531011 (0x00269EC3) ao resultado
    ; para 64 bits, é preciso carry
    MOV R2, #0xC3   ; Parte inferior
    MOVT R2, #0x9E  ; Parte superior
    MOV R3, #0x26   ; Parte inferior
    ADD R0, R0, R2
    ADC R1, R1, R3

    ; atualiza seed
    LDR R4, seed_addr
    STR R0, [R4]    ; Parte inferior
    STR R1, [R4, #4]    ; Parte superior

    ; retorna o resultado (seed >> 16)
    MOV R0, R1      ; retorna os 16 bits superiores

    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    POP PC          ; retorna

main:
    MOV R0, #0
    MOV R1, #50
    MOV R2, #0
    MOV R3, #50
    BL umull32

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
    .word 0x43_FD    ; Parte inferior
    .word 0x00_03    ; Parte superior
*/
/*
2531011:
    .word 0x9E_C3    ; Parte inferior
    .word 0x00_26    ; Parte superior
*/
; verificar RAND_MAX para 32 bits (0xFFFFFFFF), como fica?
RAND_MAX:
    .word 0xFFFFFFFF
