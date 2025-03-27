a = 4321 * 214013
b = 2531011
c = a + b
d = 4294967295

print(a)
print(c)
    
def mod(a, b):
    while a >= b:
        a -= b
    
    return a

print(mod(c, d).__rshift__(16))