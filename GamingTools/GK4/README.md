# [GK4 ERP](/README.md#gk4-erp)

A great journey to construct GK4(Genghis Khan Ⅳ, KOEI, 1998) ERP


## \<List>

- [Get Provinces' Data from the Save File (2021.03.17)](#get-provinces-data-from-the-save-file-20210317)


## [Get Provinces' Data from the Save File (2021.03.17)](#list)

- Partial module of a gaming utility for `Genghis Khan Ⅳ` (KOEI, 1998)
- Call provinces' data from a save file
- Based on the previous works in `\RTK2`
- Use `os` `binascii`
- Code(`GK4_Provinces.py`) and Results
  <details>
    <summary>1. Check if the file exists and its length</summary>

  ```python
  path = ".\GK4\save1.gk"
  # print(os.path.isfile(path))                     # check if the save file exists

  filelenth = os.path.getsize(path)
  alpha = filelenth - 1344418                     # get the alpha that is added to the offset value
  ```
  </details>
  <details>
    <summary>2. Make offset initial information</summary>

  ```python
  province_offset_init = []
  province_offset_data = []
  province_num = 80                               # the maximum number of provinces = 80
  province_distance = 9298                        # each province has 9,298 bytes' data

  for i in list(range(0,80)) :
      province_offset_init.append(125916 + alpha + province_distance*i)
      province_offset_data.append(list(range(province_offset_init[i], province_offset_init[i] + province_distance)))

  # print(province_offset_init)
  # print(province_offset_data[0])
  ```
  </details>
  <details>
    <summary>3. Get provinces' data</summary>

  ```python
  with open(path,'rb') as f:
      province_raw_data = f.read()
      province_data = []

      for i in list(range(0, province_num)) :
          province_data_row = []

          for j in list(range(0, 138)) :          # try to get only core data
              province_data_row.append(province_raw_data[province_offset_data[i][j]])

          province_data.append(province_data_row)
  ```
  </details>
  <details>
    <summary>4. read provinces' data</summary>

  ```python
  print("# ", "이름           ", "소속국#", "규모", "방어", "금", "식량", "상비군", "부상병")

  for i in list(range(0, province_num)) :

      if province_data[i][0] == 255 :             # do not need to print empty data
          break

      print(province_data[i][0], " ", end='')                                 # province#
      print(bytes(province_data[i][1:22]).decode('cp949'), " ", end='')       # province name
      print(province_data[i][22], " ", end='')                                # country#
      print(province_data[i][23], " ", end='')                                # province scale
      print(province_data[i][24] + province_data[i][25]*256, " ", end='')     # province defence
      print(province_data[i][26] + province_data[i][27]*256, " ", end='')     # province gold
      print(province_data[i][28] + province_data[i][29]*256, " ", end='')     # province food
      print(province_data[i][30] + province_data[i][31]*256, " ", end='')     # province soldiers
      print(province_data[i][32] + province_data[i][33]*256)                  # province injured soldiers
  ```
  </details>
  <details open="">
    <summary>Results</summary>

  ```txt
  # 이름 소속국# 규모 방어 금 식량 상비군 부상병
  0 런던 0 6 600 5500 15000 6500 0
  1 파리 1 5 500 6500 17000 8000 0
  2 쾰른 2 4 400 8170 8373 6200 0
  3 제노바 2 4 400 8566 8668 6900 0
  ……
  51 히라이즈미 29 4 400 7200 11000 3700 0
  ```
  </details>