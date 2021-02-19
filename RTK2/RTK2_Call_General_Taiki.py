# RTK2 - Call Generals' Data from TAIKI.DAT / 20200301
# Each Geneal's Data Length : 46 bytes
# Header Data : 6 bytes


# Check If TAIKI.DAT Exists
import os

path = "C:\Game\KOEI\RTK2\TAIKI.DAT"
os.path.isfile(path)


# Get the file length
filelenth = os.path.getsize(path)
num = int((filelenth - 6) / 46)
print(num) # There're 420 General's Data


# Make Offset Initial Information
# 1) Generate an Arithmetic Progression : a1 = 7, d = 46
# 2) make (i. j) list from 1)
general_offset_init = [] # count from 0
general_offset_data = []

distance = 46
for i in list(range(0,num)) :
    general_offset_init.append(6 + distance*i)
    general_offset_data.append(list(range(general_offset_init[i], general_offset_init[i]+distance)))

len(general_offset_init)
len(general_offset_data)
print(general_offset_init[0:10])
print(general_offset_data[0:2])


# Call TAIKI.DAT
with open(path,'rb') as f:
    general_raw_data = f.read()
    general_data = []
    
    for i in list(range(0,num)) :
        general_data_row = []

        for j in list(range(0,distance)) :    
            general_data_row.append(general_raw_data[general_offset_data[i][j]])

        general_data.append(general_data_row)


print(general_data[0:3])
chr(general_data[0][0])
# Should Convert The Whole List from ASCII Code(int) to string




# Practice
for i in range(1,10) :
    print(i)
