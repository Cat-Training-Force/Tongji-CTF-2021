from flag import flag
from Crypto.Util.number import long_to_bytes,getPrime

m = bytes_to_long(flag)

e = 65537
p = getPrime(128)
q = getPrime(128)
N = p * q

c = pow(m, e, N)

print('c = ', c)
print('N = ', N)
print('e = ', e)

