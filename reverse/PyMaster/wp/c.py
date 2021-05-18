import base64
import types

def encode(s):
    return types.FunctionType(compile(base64.b64decode(b'bGFtYmRhIHM6IGJhc2U2NC5hODVlbmNvZGUoYmFzZTY0LmI4NWVuY29kZShzLmVuY29kZSgidXRmLTgiKSkp'), '', 'eval'), globals())()(s)

s=input('Input the flag:')
ss=''
bb=True
for i in s:
    if bb:
        ss+=i
        bb=False
    else:
        ss=i+ss
        bb=True
print(['Error', 'Right!'][encode(ss) == b'AP-T.:16.HD15K-/Uh;$CM"i$@Tl`;6WZK19ds(\\->>8;9kSQ0@sq0tGQ'])