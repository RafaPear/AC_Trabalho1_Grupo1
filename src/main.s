.equ STACK_SIZE, 40
.equ RAND_MAX, 0xFF
.equ N, 5

    .text

    b   program
    b . ; Reservado (ISR)

    umull32:
        push lr
        push r4
        push r5
        push r6
        push r7
        push r8
        push r9

        ; --------- IN ---------
        ; R1, R0 => M
        ; R3, R2 => m
        ; -------- OUT ---------
        ; R4, R3, R2, R1
        ; ------ INTERNAL ------
        ; r6 => TEMP_A
        ; r7 => TEMP_B
        ; r8 => p_1
        ; r9 => i


        ; Como o R3 e R2 já representam o N,
        ; para fazer int64_t p = N apenas preciso
        ; de colocar os restantes registos de maior peso
        ; = 0, ou seja, R5 e R4 = 0
        mov r4, #0
        mov r5, #0

        mov r6, #0 ; TEMP_A
        mov r7, #0 ; TEMP_B
        mov r8, #0 ; p_1
        mov r9, #0 ; i
    
    umull32_for:
        mov r6, #32
        cmp r6, r9
        beq umull32_for_end

    umull32_if:
        mov r6, #1
        and r7, r2, r6
        bzc umull32_else_if

        mov r6, #1
        cmp r6, r8
        bzc umull32_else_if

        add r4, r4, r0
        adc r5, r5, r1

        b umull32_if_end

    umull32_else_if:

        mov r6, #1
        and r7, r2, r6
        bzs umull32_if_end

        mov r6, #0
        cmp r6, r8
        bzc umull32_if_end

        sub r4, r4, r0
        sbc r5, r5, r1

    umull32_if_end:

        mov r6, #1
        and r8, r2, r6

        asr r5, r5, #1
        rrx r4, r4
        rrx r3, r3
        rrx r2, r2

        add r9, r6, r9
        b umull32_for

    umull32_for_end:
        mov r0, r2
        mov r1, r3

        pop r9
        pop r8
        pop r7
        pop r6
        pop r5
        pop r4
        pop pc

    srand:
        push r4
        ldr r4, seed_addr
        str r0, [r4]
        str r1, [r4, #2]
        pop r4
        mov pc, lr

    mod:
        push r4
        push r5
        sub r4, r0, r2
        sbc r5, r1, r3
        bcc mod_end
    mod_loop:
        sub r0, r0, r2
        sbc r1, r1, r3
        bcs mod_loop
    mod_end:
        pop r5
        pop r4
        mov pc, lr

    rand:
        push lr
        push r1
        push r2
        push r3
        push r4
        push r5

        ldr r4, seed_addr
        mov r5, #RAND_MAX
        movt r5, #RAND_MAX

        ldr r0, [r4]
        ldr r1, [r4, #2]

        ; prepara para umull32: seed * 214013
        ; 214013 = 0x000343FD (32 bits)
        mov r2, #0xFD   ; parte inferior
        movt r2, #0x43  ; parte superior
        mov r3, #0x03   ; parte inferior
        bl umull32  ; seed * 214013

        ; adiciona 2531011 (0x00269EC3) ao resultado
        ; para 64 bits, é preciso carry
        mov r2, #0xC3   ; parte inferior
        movt r2, #0x9E  ; parte superior
        mov r3, #0x26   ; parte inferior
        add r0, r0, r2
        adc r1, r1, r3

        mov r2, r5
        mov r3, r5

        bl mod
        bl srand

        ; retorna o resultado (seed >> 16)
        mov r0, r1     ; retorna os 16 bits superiores
        
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1
        pop pc    ; retorna

    seed_addr: .word seed


program:
    ldr sp, stack_top_addr
    b main
stack_top_addr:
    .word stack_top

main:
    ; -------- Variáveis --------
    ; r0 => rand_number / erro
    ; r4 => TEMP_A r3
    ; r5 => TEMP_B r4
    ; r6 => i r2

    ; Parametros para o Srand
    mov r0, #0x2F  ; r0 = 47
    movt r0, #0x15 ; r0 = 5423
    mov r1, #0     ; r1 = 0

    bl srand

main_for_init:
    mov r6, #0 ; i = 0
main_for:
    mov r4, #N
    cmp r6, r4 ; i < N
    ; predefine r0 = 0 para error = 0 caso
    ; a condicao se verifique
    mov r0, #0
    bhs .

    bl rand ; r0 = rand_number
    
    ldr r4, result_addr
    lsl r5, r6, #1 ; i * 2 para indexar corretamente
    ldr r5, [r4, r5]
    add r6, r6, #1
    cmp r0, r5
    bzs main_for
    mov r0, #1
    b .

    result_addr: .word result

    .data  ; Variáveis globais

    result:
        .word 17747, 2055, 3664, 15611, 981
    
    seed:
        .word 1, 0

    .stack

    .space  STACK_SIZE
stack_top:
