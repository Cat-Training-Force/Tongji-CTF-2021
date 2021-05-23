#include <stdio.h>
#include <string.h>

int main()
{
    char buf[255];
    printf("Input the flag:\n");
    fgets(buf, 100, stdin);
    if (strcmp(buf, "tjctf{welCOME_To_rEvEr$3}\n") == 0)
        printf("Right!\n");
    else
        printf("Error!\n");
    return 0;
}