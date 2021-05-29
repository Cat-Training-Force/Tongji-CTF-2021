
ida打开，进入正常分析流程，读取字符串之后调用了sub_19EE,这是个深层调用，可以使用IDA脚本查看函数终点

sub_19EE以及深层调用都是这个模式

```asm
.text:00000000000019EE sub_19EE        proc near               ; CODE XREF: main+4A↓p
.text:00000000000019EE ; __unwind {
.text:00000000000019EE                 endbr64
.text:00000000000019F2                 push    rbp
.text:00000000000019F3                 mov     rbp, rsp
.text:00000000000019F6                 mov     eax, 0
.text:00000000000019FB                 call    sub_19D9
.text:0000000000001A00                 nop
.text:0000000000001A01                 pop     rbp
.text:0000000000001A02                 retn
```
可以使用这个python脚本找到终点
```python
start=0x19EE
e=get_bytes(start+0x19fb-0x19ee,5)
while e[0]==0xe8:
    dif=e[1]+(e[2]<<8)+(e[3]<<16)+(e[4]<<24)
    if dif>0x7fffffff:
        dif-=0x100000000
    start+=dif+0x19fb-0x19ee+5
    print(hex(start))
    e=get_bytes(start+0x19fb-0x19ee,5)c
```

最后找到了sub_11A9，查看这个函数（需要修复），发现如果ptrace返回-1就死循环

然后读取数据，对数据的每一个元素，都调用了sub_286A。这里也是一个深层调用，可以稍加修改上面的脚本然后查看终点。和上面的不同的是，每一次调用都增加参数，即这个调用形式如下

```c
char fci(char c){
    return fci+1(c)+c;
}
```
所以调用i次相当于c*i（本题调用了素数次保证唯一性←_←）。最终是一个ptrace。由于上面已经调用过ptrace，所以这里再次调用应该返回-1，最终表达式为

input[i]=input[i]*调用次数-1

最终进入sub_2902进行验证，input[i]=input[i]^i，再和qword_7020进行比对。注意这里的数据已经发生替换，所以静态数据肯定得到fake flag。

有两种方法得到原始数据

1. main函数之前查看init、fini对qword_7020的操作
2. qword_7020交叉引用得到新数据
3. 过掉上面的反调试，调试到qword_7020

当然，由于都是按字节变化，也可以尝试插桩或angr