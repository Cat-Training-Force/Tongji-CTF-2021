storeImm 0
mov 1,0
storeImm "正确！请提交md5(input)，input为你输入的数字空格分隔，不要多出空格，例如1 2 3"
store 0,10,1,1
storeImm "Oops... wrong"
store 0,11,1,1

storeImm 2
store 0,64,1,1
storeImm -1
store 0,65,1,1
storeImm 4
store 0,66,1,1
storeImm 5
store 0,67,1,1
storeImm 6
store 0,68,1,1
storeImm 1
store 0,69,1,1
storeImm 3
store 0,70,1,1
storeImm 4
store 0,71,1,1
storeImm 5
store 0,72,1,1
storeImm -1
store 0,73,1,1
storeImm 1
store 0,74,1,1
storeImm 2
store 0,75,1,1
storeImm 4
store 0,76,1,1
storeImm 5
store 0,77,1,1
storeImm -1
store 0,78,1,1
storeImm 1
store 0,79,1,1
storeImm 2
store 0,80,1,1
storeImm 3
store 0,81,1,1
storeImm 1
store 0,82,1,1
storeImm 2
store 0,83,1,1
storeImm 3
store 0,84,1,1
storeImm 4
store 0,85,1,1
storeImm 5
store 0,86,1,1
storeImm -1
store 0,87,1,1
storeImm -1
store 0,88,1,1
storeImm 6
store 0,89,1,1
storeImm 1
store 0,90,1,1
storeImm 2
store 0,91,1,1
storeImm -1
store 0,92,1,1
storeImm 4
store 0,93,1,1
storeImm 6
store 0,94,1,1
storeImm 1
store 0,95,1,1
storeImm -1
store 0,96,1,1
storeImm 3
store 0,97,1,1
storeImm 4
store 0,98,1,1
storeImm 5
store 0,99,1,1

# 外层循环用1，内层循环用2
storeImm 0
mov 3,0
mov 2,0
mov 1,0

# 32开始的存储区用作暂存区
LAB21:
storeImm -36
add 0,1
je LAB1
storeImm 0
mov 2,0
LAB20:
storeImm -6
add 0,2
je LAB2
store 1,32,3,3
load 1,64,1,2
storeImm 1
add 0,1
jne LAB3
input
load 1,32,3,3
store 0,64,1,2
LAB3:
load 1,32,3,3
storeImm 1
add 2,0
jmp LAB20
LAB2:
storeImm 6
add 1,0
jmp LAB21
LAB1:

# 这里开始检测
storeImm 0
mov 1,0
mov 2,0
mov 3,0

# 检测行
LAB11:
storeImm -36
add 0,1
je LAB4
storeImm 0
mov 2,0
LAB6:
storeImm -6
add 0,2
je LAB5
storeImm 0
store 0,40,0,2
storeImm 1
add 2,0
jmp LAB6
# 以40处为起始做标记
LAB5:
storeImm 0
mov 2,0
LAB8:
storeImm -6
add 0,2
je LAB7
load 3,64,1,2
storeImm 0
store 1,32,0,0
storeImm 0
mov 1,0
storeImm 1
store 0,40,3,1
storeImm 0
load 1,32,0,0
storeImm 1
add 2,0
jmp LAB8
# 检测标记
LAB7:
storeImm 0
mov 2,0

LAB10:
storeImm -6
add 0,2
je LAB9
storeImm 0
load 3,41,2,0
storeImm -1
add 0,3
jne FAILED
storeImm 1
add 2,0
jmp LAB10
LAB9:
# 外层循环
storeImm 6
add 1,0
jmp LAB11
LAB4:

storeImm 0
mov 2,0
mov 3,0
mov 1,0
# 检测列
LAB19:
storeImm -6
add 0,1
je LAB12
storeImm 0
mov 2,0
LAB14:
storeImm -6
add 0,2
je LAB13
storeImm 0
store 0,40,0,2
storeImm 1
add 2,0
jmp LAB14
LAB13:
# 以40处为起始做标记
storeImm 0
mov 2,0
LAB16:
storeImm -6
add 0,2
je LAB15
storeImm 6
mul 0,2
load 3,64,1,0
storeImm 0
store 1,32,0,0
storeImm 0
mov 1,0
storeImm 1
store 0,40,3,1
storeImm 0,0
load 1,32,0,0
storeImm 1
add 2,0
jmp LAB16
LAB15:
# 检测标记
storeImm 0
mov 2,0
LAB18:
storeImm -6
add 0,2
je LAB17
storeImm 0
load 3,41,2,0
storeImm -1
add 0,3
jne FAILED
storeImm 1
add 2,0
jmp LAB18
# 外层循环
LAB17:
storeImm 1
add 1,0
jmp LAB19
LAB12:
# 成功
storeImm 0
mov 1,0
load 0,10,1,1
output
jmp SUCC
FAILED:
storeImm 0
mov 1,0
load 0,11,1,1
output
SUCC: