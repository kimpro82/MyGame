# get current working directory
import os

os.getcwd()
print(os.getcwd())

# check if the file exists
os.path.isfile("path")


import binascii

# with문
with open('path','rb') as f: # rb : read & binary
    string = f.read()
    print(string[0:10])
    print(binascii.b2a_hex(string[0:10]))

# with문 X
f = open('path','rb')
data = f.read()
print(data[0:10])
print(binascii.b2a_hex(data[0:10]))
f.close()

# decimal → hexadecimal
hex(30000)
hex(3000000)
hex(100)

# hexadecimal → decimal
int('7530', 16)
int('2dc6c0', 16)
int('64', 16)
