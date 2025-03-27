main:

    mov r1, #0
    mov r0, #99
    mov r3, #0
    mov r2, #99
    bl umull32
    bl srand
    b .
