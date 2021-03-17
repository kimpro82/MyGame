import os
import binascii


# 1. check if the file exists and its length

saveFileName = "save1.gk"
# print(os.path.isfile(saveFileName))           # check if the save file exists

filelenth = os.path.getsize(saveFileName)
alpha = filelenth - 1344418                     # get the alpha that is added to the offset value


# 2. make offset initial information

province_offset_init = []
province_offset_data = []
province_num = 80                               # the maximum number of provinces = 80
province_distance = 9298                        # each province has 9,298 bytes' data

for i in list(range(0,80)) :
    province_offset_init.append(125916 + alpha + province_distance*i)
    province_offset_data.append(list(range(province_offset_init[i], province_offset_init[i] + province_distance)))

# print(province_offset_init)
# print(province_offset_data[0])


# 3. get provinces' data

with open(saveFileName,'rb') as f:
    province_raw_data = f.read()
    province_data = []

    for i in list(range(0, province_num)) :
        province_data_row = []

        for j in list(range(0, 138)) :          # try to get only core data
            province_data_row.append(province_raw_data[province_offset_data[i][j]])

        province_data.append(province_data_row)


# 4. read provinces' data

print("도시#", "이름", "소속국#", "규모", "방어", "금", "식량", "상비군", "부상병")

for i in list(range(0, province_num)) :

    if province_data[i][0] == 255 :             # do not neet to print empty data
        break

    print(province_data[i][0], " ", end='')                                 # province #
    print(bytes(province_data[i][1:22]).decode('cp949'), " ", end='')       # province name
    print(province_data[i][22], " ", end='')                                # country #
    print(province_data[i][23], " ", end='')                                # province scale
    print(province_data[i][24] + province_data[i][25]*256, " ", end='')     # province defence
    print(province_data[i][26] + province_data[i][27]*256, " ", end='')     # province gold
    print(province_data[i][28] + province_data[i][29]*256, " ", end='')     # province food
    print(province_data[i][30] + province_data[i][31]*256, " ", end='')     # province soldiers
    print(province_data[i][32] + province_data[i][33]*256)                  # province injured soldiers