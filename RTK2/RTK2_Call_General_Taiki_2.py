'''
RTK2 - Call Generals' Data from TAIKI.DAT (2) / 20210318

Each Geneal's Data Length : 46 bytes
Header Data : 6 bytes

00~09 출현년도,무장혈연,출현지역,공백, 공백,공백,공백,지력,무력,매력,
10~19 의리,인덕,야망,소속,충성,       봉직기간,FF,공백,상성,공백,
20~29 공백,공백,공백,공백,공백,       공백,공백,공백,출생년도,얼굴(혈연),
30~46 얼굴,이름~
(참고 ☞ https://blog.naver.com/yhz1123/220600881233)
'''


# 1. Check If TAIKI.DAT Exists and get the file's length

import os

path = "C:\Game\KOEI\RTK2\TAIKI.DAT"
# print(os.path.isfile(path))                                 # True

filelenth = os.path.getsize(path)
num = int((filelenth - 6) / 46)
# print(num)                                                  # There're 420 General's Data


# 2. Make Offset Initial Information

'''
1) Generate an Arithmetic Progression : a1 = 7, d = 46
2) make (i. j) list from 1)
'''

general_offset_init = []
general_offset_data = []

distance = 46
for i in list(range(0, num)) :
    general_offset_init.append(6 + distance * i)
    general_offset_data.append(list(range(general_offset_init[i], general_offset_init[i] + distance)))

# print(len(general_offset_init))                             # 420
# print(len(general_offset_data))                             # 420
# print(general_offset_init[0:10])                            # [6, 52, 98, 144, 190, 236, 282, 328, 374, 420]
# print(general_offset_data[0:3])                             # [[6, 7, ……, 51], [52, 53, ……, 97], [98, 99, ……, 143]] 


# 3. Call TAIKI.DAT

with open(path, 'rb') as f:
    general_raw_data = f.read()
    general_data = []
    
    for i in list(range(0, num)) :
        general_data_row = []

        for j in list(range(0, distance)) :    
            general_data_row.append(general_raw_data[general_offset_data[i][j]])

        general_data.append(general_data_row)


# 4. Read The Data

# print(general_data[0:10])
'''
[[190, 255, 20, 0, 0, 0, 0, 51, 92, 52, 79, 56, 71, 255, 0, 0, 255, 0, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 175, 39, 0, 71, 97, 110, 32, 78, 105, 110, 103, 0, 0, 0, 0, 0, 0, 0],
[190, 255, 8, 0, 0, 0, 0, 34, 52, 53, 60, 47, 52, 255, 0, 0, 255, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 167, 83, 145, 87, 97, 110, 103, 32, 90, 104, 111, 110, 103, 0, 0, 0, 0, 0], 
[190, 255, 20, 0, 0, 0, 0, 25, 31, 15, 16, 18, 32, 255, 0, 0, 255, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 153, 31, 152, 72, 97, 110, 32, 72, 97, 111, 0, 0, 0, 0, 0, 0, 0, 0], 
[190, 255, 2, 0, 0, 0, 0, 85, 99, 92, 90, 88, 70, 255, 0, 0, 255, 0, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 156, 113, 0, 90, 104, 97, 111, 32, 89, 117, 101, 0, 0, 0, 0, 0, 0, 0], 
[190, 255, 5, 0, 0, 0, 0, 65, 76, 68, 66, 63, 71, 255, 0, 0, 255, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 146, 215, 150, 67, 104, 117, 110, 32, 89, 117, 113, 105, 111, 110, 103, 0, 0, 0], 
[190, 255, 8, 0, 0, 0, 0, 30, 42, 41, 47, 36, 48, 255, 0, 0, 255, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 153, 210, 130, 66, 97, 111, 32, 88, 105, 110, 0, 0, 0, 0, 0, 0, 0, 0], 
[190, 255, 19, 0, 0, 0, 0, 46, 42, 52, 59, 41, 44, 255, 0, 0, 255, 0, 70, 0, 0, 0, 0, 0, 0, 0, 0, 0, 158, 122, 147, 71, 111, 110, 103, 32, 90, 104, 105, 0, 0, 0, 0, 0, 0, 0], 
[190, 255, 28, 0, 0, 0, 0, 80, 33, 42, 55, 53, 57, 255, 0, 0, 255, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 163, 190, 0, 89, 117, 97, 110, 32, 80, 117, 0, 0, 0, 0, 0, 0, 0, 0], 
[190, 255, 9, 0, 0, 0, 0, 81, 40, 92, 84, 88, 63, 255, 0, 0, 255, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 170, 150, 0, 77, 97, 110, 32, 67, 104, 111, 110, 103, 0, 0, 0, 0, 0, 0], 
[190, 255, 13, 0, 0, 0, 0, 23, 52, 26, 13, 38, 39, 255, 0, 0, 255, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 175, 43, 155, 77, 97, 32, 87, 97, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
'''
readlocation = (0, 2, 1, 28) + tuple(list(range(7, 13))) + (18,)
# print(readlocation)                                        # (0, 2, 1, 7, 8, 9, 10, 11, 12, 18)

print("이름", "출현연도", "출현지역", "혈연", "출생연도", "지력", "무력", "매력", "의리", "인덕", "야망", "상성")

# for i in list(range(0, 10)) :                                # Test
for i in list(range(0, len(general_offset_init) - 2)) :      # The last two rows are empty

    print(bytes(general_data[i][31:46]).decode('utf-8').ljust(15), " ", end='')                 # name : [31:46]

    for j in readlocation :
        # general_data[i][2] += 1                                 # Wrong results but can't find the reason
        print(str(general_data[i][j]).rjust(3), " ", end='')    # Other values

    print(" ")

    # general_data[i][2] += 1                                                                     # Right ex) Zhao Yue / 3
    # print(str(general_data[i][2]).rjust(3))                                        # appearance province


# 혈연 : 255 = 혈연 없음
# 출현지역 : 0~40 ex) 2 = 3번땅