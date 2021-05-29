
a=[
    [2,-1,4,5,6,1],
    [3,4,5,-1,1,2],
    [4,5,-1,1,2,3],
    [1,2,3,4,5,-1],
    [-1,6,1,2,-1,4],
    [6,1,-1,3,4,5]
]
b=[]
for i in a:
    b+=i
print(len(b))
for i in range(len(b)):
    print('storeImm %d'%b[i])
    print("store 0,%d,1,1"%(64+i))
'''
1 input
2 output
3 add
4 je
5 jne
6 jmp
7 storeImm
8 store
9 load
10 mul
11 mov
'''
code=''
with open('code.asm','r') as f:
    code=f.read()
cmd={
    'input':1,
    'output':2,
    'add':3,
    'je':4,
    'jne':5,
    'jmp':6,
    'storeImm':7,
    'store':8,
    'load':9,
    'mul':10,
    'mov':11
}
labs=dict()
mcode=[]
cnt=0
# 扫描label
for c in code.split('\n',-1):
    if c.endswith(':'):
        labs[c[:-1]]=cnt
        continue
    elif c and c[0]!='#':
        cnt+=1
print(labs)
line=0
cmd_cnt=0
for c in code.split('\n',-1):
    line+=1
    if not c or c.endswith(':') or c.startswith('#'):continue
    cs=c.split(' ',1)
    cm=cmd[cs[0]]
    acmd=[]
    acmd.append(cm)
    # print(cs)
    if cs[0].startswith('j'):
        acmd.append(labs[cs[1]]-cmd_cnt)
    elif len(cs)>=2:
        try:
            acmd+=[int(i) for i in cs[1].split(',',-1)]
        except:
            acmd+=cs[1].split(',',-1)
    cmd_cnt+=1
    acmd.append(line)
    mcode.append(acmd)
print(mcode)
# from vm_in_vm import Vm
# Vm().start(mcode)
# code=''
# with open('code.asm','r') as f:
#     code=f.read()
# cmd={
#     'input':[1,2],
#     'output':[2,2],
#     'add':[3,4],
#     'je':[4,3],
#     'jne':[5,3],
#     'jmp':[6,3],
#     'storeImm':[7,3],
#     'store':[8,3],
#     'load':[9,6],
#     'mul':[10,4],
#     'mov':[11,4]
# }
# labs=dict()
# mcode=[]
# cnt=0
# for c in code.split("\n",-1):
#     if not c or c.startswith('#'):continue
#     if c.endswith(':'):
#         labs[c[:-1]]=cnt
#         continue

