.equ STACK_SIZE, 7 ; Depois ver se é 64 ou não!

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
        mov r6, #0
        cmp r7, r6
        bne umull32_else_if

        mov r6, #1
        cmp r6, r8
        bzc umull32_else_if

        add r4, r4, r0
        adc r5, r5, r1

        b umull32_if_end

    umull32_else_if:

        mov r6, #1
        and r7, r2, r6
        cmp r7, r6
        bne umull32_if_end

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
        mov r2, r4
        mov r3, r5

        pop r9
        pop r8
        pop r7
        pop r6
        pop r5
        pop r4
        pop pc

    srand:
        push r4
        ;ldr r4, seed_addr (dava: error! intervalo entre pc e target address: +132 (0x84), isn't codable with 7 bit)
        ;solução: carregar o address da seed para r4, diretamente e depois dar load para r4
        mov r4, #seed_addr
        str r0, [r4]
        str r1, [r4, #2]
        pop r4
        mov pc, lr

    mod:
        cmp r1, R3
        bhs mod_end
        sub r0, r0, r2
        sbc r1, r1, r3
        b mod
    mod_end:
        mov pc, lr

    rand:
        push lr
        push r1
        push r2
        push r3
        push r4
        ; seed atual (32 bits) -> r0 e r1
        mov r4, #seed_addr
        ldr r0, [r4]    ; parte inferior
        ldr r1, [r4, #2]    ; parte superior

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
        ldr r2, [r4]
        ldr r3, [r4, #2]

        bl mod

        ; atualiza seed
        str r0, [r4]    ; parte inferior
        str r1, [r4, #2]    ; parte superior

        ; retorna o resultado (seed >> 16)
        mov r0, r1     ; retorna os 16 bits superiores

        pop r4
        pop r3
        pop r2
        pop r1
        pop pc    ; retorna

program:
    ldr sp, stack_top_addr
    b main
stack_top_addr:
    .word stack_top

main:
    mov r7, #0  ; r7 = error = 0
    mov r4, #0  ; r4 = i = 0

    ; srand(5423)
    ; 5423 = 0x152F (16 bits)
    mov r0, #0x2F   ; parte inferior
    movt r0, #0x15  ; parte superior
    mov r1, #0  ; parte superior (só zeros)
    bl srand

main_for_loop:
    ; for (i = 0; error == 0 && i < n; i++)
    ; error == 0 && i < n
    mov r5, #0 ; r5 = 0
    cmp r7, r5  ; error == 0
    bne main_end_for_loop   ; se error != 0, dá break

    ; load no n para a comparação (i < n)
    mov r5, #n
    cmp r4, r5  ; i < n
    bge main_end_for_loop   ; se i >= n, dá break

    bl rand     ; rand() -> retorna em r0 = rand_number

    ; result[i] = rand_number (result é um array de uint16_t [2 bytes cada elemento] -> offset = i * 2)
    mov r5, #result_addr
    lsl r6, r4, #1 ; r6 = i * 2
    ldr r6, [r5, #2] ; r6 = result[i]

    cmp r0, r6 ; compara result[i] com rand_number
    bne error
    add r4, r4, #1  ; i++
    b main_for_loop

error:
    mov r7, #1  ; error = 1 se forem diferentes

main_end_for_loop:
    mov r0, r7  ; r0 = error

    .data  ; Variáveis globais
    result_addr: .word result

    seed_addr: .word seed

    n: .word 5

    rand_max: .word 0xFFFF

    seed: .word 1, 0

    result: .word 0x4553, 0x807, 0xE50, 0x3CFB, 0x2658

    .stack

    .space  STACK_SIZE
stack_top:
