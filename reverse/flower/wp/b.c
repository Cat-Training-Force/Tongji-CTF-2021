#include <stdio.h>


void f(){
    __asm__ __volatile__(
        "pop %rdx\n"
        "pop %rax\n"
        "add $1,%rax\n"
        "push %rax\n"
        "push %rdx\n"
    );
}
int main()
{
    
    char buf[255];
    printf("Input the flag:\n");
    fgets(buf, 100, stdin);
    long long key = 0x79656b5f7473756a;
    char enc[] = { 30, 31, 16, 0, 57, 16, 0, 55, 32, 69, 10, 43, 7, 91, 23, 38, 29, 60, 68, 60, 0, 13, 9, 73, 29, 70, 1, 43, 14, 28, 52, 4 };
    int sz = sizeof(enc) / sizeof(char);
    if (buf[sz] != '\n')
    {
        printf("Error!\n");
        return 0;
    }
    buf[sz] = 0;
    __asm__ __volatile__(
        "jz NEXT1\n"
        "jnz NEXT1\n"
        ".byte 0xff\n"
        "NEXT1:"
    );
    for (int i = 0; i < sz; i++)
    {
        
        __asm__ __volatile__(
            "call f\n"
            ".byte 0xff"
        );
        if (buf[i] ^ enc[i] ^ *((char *)&key + i % 8))
        {
            printf("Error!\n");
            return 0;
        }
    }
    printf("Right!\n");
    return 0;
}