#include <stdint.h>
#include <stdio.h>

uint32_t umull32(uint32_t M, uint32_t m) {
    int32_t M_ext = M;
    int32_t result = m;
    uint8_t p_1 = 0;

    for (uint8_t i = 0; i < 16; i++) {
        printf("result & 0x1: %d\n", (result & 0x1));
        if ((result & 0x1) == 0 && p_1 == 1) {
            // 00000000000000020000000000000000
            // 00000000000000000000000000000000
            result += M_ext << 16;
            printf("result: %d\n", result);
        } else if ((result & 0x1) == 1 && p_1 == 0) {
            result -= M_ext << 16;
            printf("result: %d\n", result);
        }
        p_1 = result & 0x1;
        printf("p_1: %d\n", p_1);
        result >>= 1;
        printf("result: %d\n", result);
    }
    return result;
}

int main(int argc, char *argv[]) {
    uint32_t M = (uint32_t)argv[0];
    uint32_t m = (uint32_t)argv[1];
    uint32_t result = umull32(M, m);
    printf("result: %d\n", result);
    return 0;
}