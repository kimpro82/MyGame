# province_offset_data
province_offset_init = []
province_offset_data = []

for i in list(range(0,41)) :
    province_offset_init.append(11668 + 35*i)
    province_offset_data.append(list(range(province_offset_init[i], province_offset_init[i]+35)))


# call the save data on each offset location
with open('Documents/신랑/개발/Python/SAVE','rb') as f:
    province_law_data = f.read()
    province_data = []
    
    for i in list(range(0,41)) :
        province_data_row = [] 
        for j in list(range(0,35)) :    
            province_data_row.append(province_law_data[province_offset_data[i][j]])
        province_data.append(province_data_row)

print(province_data[0:3])


# test : gold
province_gold = []

for i in list(range(0,41)) :
    province_gold.append(province_data[i][0] + province_data[i][1]*256)

print(province_gold)


# all province data
province_gold = []
province_food = []
province_pop = []
province_rate = []
province_horses = []
province_loy = []
province_land = []
province_flood = []
province_forts = []

for i in list(range(0,41)) :
    province_gold.append(province_data[i][0] + province_data[i][1]*(2**8))
    province_food.append(province_data[i][2] + province_data[i][3]*(2**8) + province_data[i][4]*(2**16))
    province_pop.append((province_data[i][6] + province_data[i][7]*(2**8))*100)
    province_rate.append(province_data[i][19])
    province_horses.append(province_data[i][17])
    province_loy.append(province_data[i][15])
    province_land.append(province_data[i][14])
    province_flood.append(province_data[i][16])
    province_forts.append(province_data[i][18])

print("Province", "Pop\t\t", "Gold\t", "Food\t\t", "Rate Horses Loy Land Flood Forts")
for i in list(range(0,10)) :
    print(i+1, "\t", province_pop[i], "\t", province_gold[i], "\t", province_food[i], "\t", end =' ')
    print(province_rate[i], province_horses[i], province_loy[i], province_land[i], province_flood[i], province_forts[i])
