添加了几条花指令，直接去掉这些花指令就可以

第一种
```c
__asm__ __volatile__(
        "jz NEXT1\n"
        "jnz NEXT1\n"
        ".byte 0xff\n"
        "NEXT1:"
    );
```
ida使用递归下降反汇编算法，即跟随控制流。反汇编jnz时，会同时从jnz成功和失败两个分支分析。那么jnz失败分支就会分析失败。

```c
__asm__ __volatile__(
            "call f\n"
            ".byte 0xff"
        );

__asm__ __volatile__(
        "pop %rdx\n"
        "pop %rax\n"
        "add $1,%rax\n"
        "push %rax\n"
        "push %rdx\n"
    );
```

这个明显，将返回地址+1

直接nop掉就可以了。然后就是正常的流程。

如果调试就可以无视花指令了，所以说看到行为之后掩饰苍白无力 ;-)