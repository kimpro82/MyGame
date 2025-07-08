# [RTK2 ERP / Python](/README.md#rtk2-erp)

a great journey to construct RTK2(Romance of The Three Kingdoms II, KOEI, 1989) ERP


## List

- [Read the Save Data in a Linked List Structure (2025.07.06)](#read-the-save-data-in-a-linked-list-structure-20250706)
- [Get Portraits from `KAODATA.DAT` (Trial 2) (2024.08.05)](#get-portraits-from-kaodatadat-trial-2-20240805)
- [Get Portraits from `KAODATA.DAT` (Trial 1) (2023.03.09)](#get-portraits-from-kaodatadat-trial-1-20230309)
- [Get Generals' Data from `TAIKI.DAT` 2 (2021.03.18)](#get-generals-data-from-taikidat-2-20210318)
- [Get Generals' Data from `TAIKI.DAT` 1 (2020.03.01)](#get-generals-data-from-taikidat-1-20200301)
- [Get Provinces' Data from the Save File with `Pandas` (2019.08.12)](#get-provinces-data-from-the-save-file-with-pandas-20190812)
- [Get Provinces' Data from the Save File (2019.07.23)](#get-provinces-data-from-the-save-file-20190723)
- [Get Provinces Data's Offset from the Save File (2019.07.22)](#get-provinces-datas-offset-from-the-save-file-20190722)


# [Read the Save Data in a Linked List Structure (2025.07.06)](#list)

- A long-standing goal has been achieved!
- Successfully analyzed the linked list structure of the save data and sorted ruler, province, and general data accordingly.
- For practical use in gameplay, migration to VBA is required.

- Code Structure : `RTK2_SaveData_Extractor.py`
  <details>
    <summary>Flowchart</summary>

  ```mermaid
  flowchart TD
      A[Start: Main] --> B[read_binary_file]
      B --> C[extract_generals_from_save]
      C --> D[extract_provinces_with_generals]
      D --> E[extract_rulers_with_provinces_and_generals]
      E --> F[link_provinces_by_ruler]
      F --> G[link_generals_by_province]
      G --> H[summarize_province_with_generals]
      H --> I[summarize_ruler_with_provinces_and_generals]
      I --> J[Print sample outputs]
      J --> K[save_dataframes_to_csv]
      K --> L[End]

      subgraph Extraction
          B
          C
          D
          E
      end
      subgraph Arrangement
          F
          G
      end
      subgraph Aggregation
          H
          I
      end
      subgraph Output
          J
          K
      end
  ```
  </details>
- Results
  <details open="">
    <summary>Console Output</summary>

  ```py
  General DataFrame (first 5 rows):
    general_idx  next_gen_idx       name  int  war  cha  fai  vir  amb  ruler_idx  loy  exp  syn  soldiers  weapons  trainning  birth  face  prov_idx prov_governor prov_ruler
  0            0            60    Cao Cao   95   91   95   60   65   99          0    0    1    1     10000     1000         80    155   103        17       Cao Cao    Cao Cao
  1           60            76    Sima Yi   98   67   93   88   73   98          0   95    1    2      1000      100         80    179    79        17       Cao Cao    Cao Cao
  2           76            86     Cao Pi   76   70   80   82   84   83          0  100    1    1      1000      100         80    187   104        17       Cao Cao    Cao Cao
  3           86            87  Cao Zhang   60   92   72   86   78   76          0  100    1    1      1000      100         80    190    98        17       Cao Cao    Cao Cao
  4           87            88    Cao Zhi   80   15   80   82   82   18          0  100    1    1      1000      100         80    192    99        17       Cao Cao    Cao Cao 

  Province DataFrame 2 (first 5 rows):
    prov_idx  next_prov_idx  governor_idx     governor  gold   food     pop  ruler_idx  loy  land  flood  horses  forts  rate  merch  state ruler_name  soldiers_sum  gen_cnt  free_cnt
  0        17             18             0      Cao Cao  3000  70000  200000          0   73    74     67      10      4    55   True      9    Cao Cao         20000       11         0
  1        18             13            18   Zhang Liao  2500  45000  250000          0   72    66     66      10      3    57  False      9    Cao Cao         12000        8         0
  2        13              8            14     Zhang Lu  2500  30000  240000          0   70    80     75      10      3    52  False      6    Cao Cao          5000        1         0
  3         8             29             9   Xiahou Dun  2500  35000   80000          0   65    67     72      10      2    55  False      3    Cao Cao          6000        2         0
  4        29             11            27  Xiahou Yuan  2500  45000  300000          0   65    81     67       5      3    48   True     12    Cao Cao         10000        6         0 

  Ruler DataFrame (first 5 rows):
    ruler_idx ruler_name capital_idx  advisor_idx advisor_name  trust  prov_cnt  gold_sum  food_sum  pop_sum  soldiers_sum  gen_cnt  free_cnt
  0          0    Cao Cao          17           60      Sima Yi     50        18     45500    680000  4560000        143000       66         0
  1          1    Liu Bei          33           40  Zhuge Liang     50         7      4000    210000  2830000         87000       54         0
  2          2   Sun Quan          24           54        Lu Su     50        12      6500    200000  2790000         92000       39         0
  3          3   Meng Huo          36           -1                  50         1      1000     35000    85000         17000        8         0
  4         -1                                  -1                   0         0         0         0        0             0        0         0 

  DataFrames have been saved to ./Data as CSV files (sep=',').
  ```
  </details>


# [Get Portraits from `KAODATA.DAT` (Trial 2) (2024.08.05)](#list)

- Although it is not completely finished, some progress has been made

  ![2_1](./Images/RTK2_Portraits2_1.gif)
  ![2_2](./Images/RTK2_Portraits2_2.gif)
  ![2_3](./Images/RTK2_Portraits2_3.gif)

  - Confirm the correct identification of the portrait image data positions for each character in `KAODATA.DAT`
  - Separate the palette data into a separate *JSON* file
  - Reference ☞ [gcjjyy](https://github.com/gcjjyy) > [koei_viewer](https://github.com/gcjjyy/koei_viewer)
- Future tasks
  - Consider endianness when extracting 3-bit palette data
Ensure accurate color mapping
  - Integrate the images into a 2D grid structure instead of a vertical layout
- Code(`RTK2_Portraits_2.py`) and Console Output
  <details>
    <summary>Import modules and declare constants</summary>

  ```py
  import os
  import json
  from PIL import Image   # Pillow
  ```
  ```py
  # Parameters
  IS_TEST         = True  # True : Test Mode
  LOAD_PATH       = "./KAODATA.DAT"
  PALETTE_PATH    = "./RTK2_Palette.json"
  PALETTE_NAME    = "palette_rtk2_3"
  SAVE_PATH       = "./Images/RTK2_Portraits2.gif"
  TEST_PATH       = "./Images/RTK2_Portraits2_Test.gif"
  WIDTH           = 64
  ```
  </details>
  <details>
    <summary>Read data and palette files </summary>

  ```py
  def read_data_file(_path):
      """
      Reads binary data from the specified file.

      Args:
          _path (str): The path to the file to be read.

      Returns:
          bytes: The binary data read from the file.
      """
      if os.path.isfile(_path):
          with open(_path, "rb") as f:
              _data = f.read()
              if IS_TEST:
                  for i in range(3):
                      print(f"  data[{i}] : {chr(_data[i])} {_data[i]:3d} {bin(_data[i])}")
                  print("  ……")
              return _data
      else:
          print("  There's no target file.")
          exit()
  ```
  ```py
  def read_palette_file(_path):
      """
      Reads the palette data from the specified JSON file.

      Args:
          _path (str): The path to the JSON file.

      Returns:
          list of list of int: The palette data read from the JSON file.
      """
      if os.path.isfile(_path):
          with open(_path, "r", encoding="utf-8") as f:
              palette_data = json.load(f)
              if IS_TEST:
                  for el in palette_data[PALETTE_NAME]:
                      print(f"  palette : {el}")
              return palette_data[PALETTE_NAME]
      else:
          print("  There's no palette file.")
          exit()
  ```
  </details>
  <details>
    <summary>Extracts 3-bit palette indices</summary>

  ```py
  def extract_3_bit_palette_indices(byte_data):
      """
      Extracts 3-bit palette indices from the given byte data.

      Args:
          data (bytes): The byte data to extract 3-bit palette indices from.

      Returns:
          list of int: The extracted 3-bit palette indices.
      """
      bit_list = []
      for index, byte in enumerate(byte_data):
          for bit_position in range(8):
              bit = (byte >> (7 - bit_position)) & 1
              bit_list.append(bit)  # Extract individual bits
          if IS_TEST:
              if index < 3:
                  print(f"  data[{index}] : {byte:3d} {bin(byte):10s} {bit_list[-8:]}")
              elif index == 3:
                  print("  ……")

      # Extract 3-bit palette indices
      palette_indices = []
      for index in range(0, len(bit_list), 3):
          if index + 2 < len(bit_list):
              palette_index = (bit_list[index] << 2) | (bit_list[index + 1] << 1) | bit_list[index + 2]
              palette_indices.append(palette_index)
              if IS_TEST:
                  if index < 24:
                      print(f"  palette_index[{int(index/3)}] : {bit_list[index:index+3]} {bin(palette_index):5s} {palette_index}")
                  elif index == 24:
                      print("  ……")
      return palette_indices
  ```
  </details>
  <details>
    <summary>Converts palette indices to RGB values</summary>

  ```py
  def convert_colors_to_rgb(_palette_indices, _palette):
      """
      Converts palette indices to RGB values using the specified palette.

      Args:
          _palette_indices (list of int): The palette indices to convert.
          _palette (list of list of int): The palette to use for conversion.

      Returns:
          list of tuple: The converted RGB values.
      """
      _rgb_colors = []
      for palette_index in _palette_indices:
          _rgb_color = tuple(_palette[palette_index])
          _rgb_colors.append(_rgb_color)
      if IS_TEST:
          for i in range(8):
              print(f"  converted_color[{i}] : {_palette_indices[i]} {_rgb_colors[i]}")
          print("  ……")
      return _rgb_colors
  ```
  </details>
  <details>
    <summary>Saves the image data as a GIF file</summary>

  ```py
  def save_image(_image_data):
      """
      Saves the image data as a GIF file.

      Args:
          _image_data (list of tuple): The RGB image data to save.
      """
      width = WIDTH
      height = int(len(_image_data) / width)
      im = Image.new(mode="RGB", size=(width, height))
      im.putdata(_image_data)
      if IS_TEST:
          crop_box = (0, 0, width, min(200, height))
          im.crop(crop_box).save(TEST_PATH)
          print(f"  The file saved as {TEST_PATH}.")
      else:
          im.save(SAVE_PATH)
          print(f"  The file saved as {SAVE_PATH}.")
  ```
  </details>
  <details>
    <summary>Run</summary>

  ```py
  # Run
  if __name__ == "__main__":
      print("Reading data file ……")
      data = read_data_file(LOAD_PATH)

      print("Reading palette file ……")
      palette = read_palette_file(PALETTE_PATH)

      print("Extracting 3-bit palette indices ……")
      extracted_palette_indices = extract_3_bit_palette_indices(data)

      print("Converting palette indices to RGB ……")
      converted_colors = convert_colors_to_rgb(extracted_palette_indices, palette)

      print("Saving image ……")
      save_image(converted_colors)
  ```
  </details>
  <details>
    <summary>Console Output</summary>

  ```txt
  Reading data file ……
    data[0] : U  85 0b1010101
    data[1] : » 187 0b10111011
    data[2] : » 187 0b10111011
    ……
  ```
  ```txt
  Reading palette file ……
    palette : [47, 31, 0]
    palette : [31, 63, 127]
    palette : [175, 63, 31]
    palette : [191, 127, 79]
    palette : [63, 111, 31]
    palette : [63, 127, 143]
    palette : [255, 175, 127]
    palette : [207, 207, 175]
  ```
  ```txt
  Extracting 3-bit palette indices ……
    data[0] :  85 0b1010101  [0, 1, 0, 1, 0, 1, 0, 1]
    data[1] : 187 0b10111011 [1, 0, 1, 1, 1, 0, 1, 1]
    data[2] : 187 0b10111011 [1, 0, 1, 1, 1, 0, 1, 1]
    ……
    palette_index[0] : [0, 1, 0] 0b10  2
    palette_index[1] : [1, 0, 1] 0b101 5
    palette_index[2] : [0, 1, 1] 0b11  3
    palette_index[3] : [0, 1, 1] 0b11  3
    palette_index[4] : [1, 0, 1] 0b101 5
    palette_index[5] : [1, 1, 0] 0b110 6
    palette_index[6] : [1, 1, 1] 0b111 7
    palette_index[7] : [0, 1, 1] 0b11  3
    ……
  ```
  ```txt
  Converting palette indices to RGB ……
    converted_color[0] : 2 (175, 63, 31)
    converted_color[1] : 5 (63, 127, 143)
    converted_color[2] : 3 (191, 127, 79)
    converted_color[3] : 3 (191, 127, 79)
    converted_color[4] : 5 (63, 127, 143)
    converted_color[5] : 6 (255, 175, 127)
    converted_color[6] : 7 (207, 207, 175)
    converted_color[7] : 3 (191, 127, 79)
    ……
  ```
  ```txt
  Saving image ……
    The file saved as ./Images/RTK2_Portraits2_Test.gif.
  ```
  </details>


# [Get Portraits from `KAODATA.DAT` (Trial 1) (2023.03.09)](#list)

- Try to extract portraits from binary data
  - Known that each **3-bits** chunk indicates a pixel of 8 colored `GIF` image
  - But the exact data pattern is not discovered yet
  - Assumption : All data would be entirely sequential
  - Use temporary palette
- Results & Next Tasks
  - **Failed**
  - Seems to need understanding about the data structure
  - Maybe the best way is to analyse other existing codes; [aaidee/RTK2face](https://github.com/aaidee/RTK2face)
- Code
  <details>
    <summary>RTK2_Portraits_1.py</summary>

  ```py
  import os
  from PIL import Image
  ```
  ```py
  # Parameters
  test = True                                                                     # True : Test Mode
  path = "C:\Game\KOEI\RTK2\KAODATA.DAT"
  palette = [
      (0, 0, 0),        # Black
      (255, 255, 255),  # White
      (255, 0, 0),      # Red
      (0, 255, 0),      # Green
      (0, 0, 255),      # Blue
      (255, 255, 0),    # Yellow
      (255, 0, 255),    # Magenta
      (0, 255, 255),    # Cyan
  ]
  ```
  ```py
  def ReadPath(path):
      if (os.path.isfile(path)):
          with open(path, "rb") as f:
              data = f.read()
              if test:
                  print("test : ", data[0], type(data[0]), bin(data[0]))          # OK : 0 85 <class 'int'> 0b1010101 ……
              return data
      else:
          print("There's no target file.")
          exit()
  ```
  ```py
  def Extract3Bits(data):
      pixels = []
      for byte in data:
          for i in range(8):                                                      # Iterate over 8 bits (== 1 byte)
              pixel_value = (byte >> (3*i)) & 0b111                               # Extract 3-bit data and guarantee always between 0 and 7 by adding `& 0b111`
              pixels.append(pixel_value)
      if test:
          print("pixels : ", pixels[:5])                                          # OK : [5, 2, 1, 0, 0]
      return pixels
  ```
  ```py
  def ConvertColors(pixels):
      image_data = [palette[pixel_value] for pixel_value in pixels]
      if test:
          print("converted colors : ", image_data[:5])                            # OK : [(255, 255, 0), (255, 0, 0), (255, 255, 255), (0, 0, 0), (0, 0, 0)]
      return image_data
  ```
  ```py
  def SaveImage(image_data):
      width = 64
      height = int(len(image_data) / width)
      im = Image.new("RGB", (width, height))
      im.putdata(image_data)
      if test:
          crop_box = (0, 0, width, min(200, height))                              # (x, y, width, height)
          image_cropped = im.crop(crop_box)
          image_cropped.save("./Images/RTK2_Portraits_Cropped.gif")
      else:
          im.save("./Images/RTK2_Portraits.gif")
  ```
  ```py
  # Run
  if __name__ == "__main__":

      # 1. Read data or do exit() if not exists
      data = ReadPath(path)

      # 2. Extract data in 3-bit chunks
      pixels = Extract3Bits(data)

      # 3. Convert each pixel value to a color from the palette
      image_data = ConvertColors(pixels)

      # 4. Save into a gif file
      SaveImage(image_data)
  ```
  </details>
  <details open="">
    <summary>Output (Not entire but partially cropped)</summary>

  ![Cropped](./Images/RTK2_Portraits_Cropped.gif)
  </details>


## [Get Generals' Data from `TAIKI.DAT` 2 (2021.03.18)](#list)

- Call and print outside generals' data from `TAIKI.DAT`
- Use `os` `bytes()`
- Not a large size data but still is open to faster enhancement

  <details>
    <summary>RTK2_General_Taiki_2.py : Mainly added/changed part</summary>

  ```python
  # 4. Read The Data

  readlocation = (0, 2, 1, 28) + tuple(list(range(7, 13))) + (18,)
  # print(readlocation)                                                                 # (0, 2, 1, 7, 8, 9, 10, 11, 12, 18)

  print("이름", "출현연도", "출현지역", "혈연", "출생연도", "지력", "무력", "매력", "의리", "인덕", "야망", "상성")

  # for i in list(range(0, 10)) :                                                       # test
  for i in list(range(0, len(general_offset_init) - 2)) :                             # The last two rows are empty

      general_data[i][2] += 1                                                         # province# : 0~40 → 1~41

      print(bytes(general_data[i][31:46]).decode('utf-8').ljust(15), " ", end='')     # name : [31:46]
      for j in readlocation :                                                         # other values
          print(str(general_data[i][j]).rjust(3), " ", end='')
      print(" ")                                                                      # line replacement
  ```
  </details>

  > 이름 출현연도 출현지역 혈연 출생연도 지력 무력 매력 의리 인덕 야망 상성  
  > Gan Ning  190   21  255  175   51   92   52   79   56   71   98  
  > Wang Zhong  190    9  255  167   34   52   53   60   47   52   10  
  > Han Hao  190   21  255  153   25   31   15   16   18   32   25  
  > Zhao Yue  190    3  255  156   85   99   92   90   88   70   50  
  > Chun Yuqiong  190    6  255  146   65   76   68   66   63   71   45  
  > Bao Xin  190    9  255  153   30   42   41   47   36   48   10  
  > Gong Zhi  190   20  255  158   46   42   52   59   41   44   70  
  > Yuan Pu  190   29  255  163   80   33   42   55   53   57   20  
  > Man Chong  190   10  255  170   81   40   92   84   88   63   10  
  > Ma Wan  190   14  255  175   23   52   26   13   38   39   20  
  > ……


## [Get Generals' Data from `TAIKI.DAT` 1 (2020.03.01)](#list)

- Call outside generals' data from `TAIKI.DAT`
- Succeed in separating each general's data, but they should convert from `ASCII Code(int)` to `string`
- Use `os`

  #### `RTK2_General_Taiki.py`

  ```python
  # Each Geneal's Data Length : 46 bytes
  # Header Data : 6 bytes
  ```

  <details>
    <summary>1. Check If TAIKI.DAT Exists and get the file's length</summary>

  ```python
  import os

  path = "C:\Game\KOEI\RTK2\TAIKI.DAT"
  ```
  ```python
  os.path.isfile(path)
  ```
  > True

  ```python
  filelenth = os.path.getsize(path)
  num = int((filelenth - 6) / 46)
  ```
  ```python
  print(num) # There're 420 General's Data
  ```
  > 420
  </details>

  <details>
    <summary>2. Make Offset Initial Information</summary>

  1) Generate an Arithmetic Progression : a1 = 7, d = 46
  2) make (i. j) list from 1)
  ```python
  len(general_offset_init)
  len(general_offset_data)
  print(general_offset_init[0:10])
  print(general_offset_data[0:2])
  ```
  > 420  
  > 420  
  > [6, 52, 98, 144, 190, 236, 282, 328, 374, 420]  
  > [[6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51], [52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97]]
  </details>

  <details>
    <summary>3. Call TAIKI.DAT</summary>

  ```python
  with open(path,'rb') as f:
      general_raw_data = f.read()
      general_data = []
      
      for i in list(range(0,num)) :
          general_data_row = []

          for j in list(range(0,distance)) :    
              general_data_row.append(general_raw_data[general_offset_data[i][j]])

          general_data.append(general_data_row)
  ```
  ```python
  print(general_data[0:3])
  ```
  > [[190, 255, 20, 0, 0, 0, 0, 51, 92, 52, 79, 56, 71, 255, 0, 0, 255, 0, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 175, 39, 0, 71, 97, 110, 32, 78, 105, 110, 103, 0, 0, 0, 0, 0, 0, 0], [190, 255, 8, 0, 0, 0, 0, 34, 52, 53, 60, 47, 52, 255, 0, 0, 255, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 167, 83, 145, 87, 97, 110, 103, 32, 90, 104, 111, 110, 103, 0, 0, 0, 0, 0], [190, 255, 20, 0, 0, 0, 0, 25, 31, 15, 16, 18, 32, 255, 0, 0, 255, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 153, 31, 152, 72, 97, 110, 32, 72, 97, 111, 0, 0, 0, 0, 0, 0, 0, 0]]
  ```python
  chr(general_data[0][0])
  # Should Convert The Whole List from ASCII Code(int) to string
  ```
  > '¾'
  </details>

  <details>
    <summary>Practice</summary>

  ```python
  for i in range(1,10) :
      print(i)
  ```
  > 1  
  > 2  
  > 3  
  > ……  
  > 9
  </details>


## [Get Provinces' Data from the Save File with `Pandas` (2019.08.12)](#list)

- Upgrade : Adopt `Numpy` & `Pandas` and convert to a `class`
- The parameter `lord` of the def `dataload` doesn't work yet.
- The columns aren't named yet, too.

  #### `RTK2_Province_Pandas.py`

  <details>
    <summary>Codes : Rtk2 (Class)</summary>

  ```python
  # Class using NumPy & Pandas
  import numpy as np
  import pandas as pd

  class Rtk2 :

      # province_offset_data
      def __init__(self) :
          self.province_offset_init = []
          self.province_offset_data = []

          for i in list(range(0,41)) :
              self.province_offset_init.append(11668 + 35*i)
              self.province_offset_data.append(list(range(self.province_offset_init[i], self.province_offset_init[i]+35)))

      # call the save data on each offset location
      def dataload(self, path, lord) :
          self.path = path
          self.lord = lord

          with open(self.path,'rb') as self.f:
              self.province_law_data = self.f.read()
              self.province_data = []

              for i in list(range(0,41)) :
                  self.province_data_row = []

                  for j in list(range(0,35)) :    
                      self.province_data_row.append(self.province_law_data[self.province_offset_data[i][j]])
                  self.province_data.append(self.province_data_row)

          self.province_data_array = np.array(self.province_data)

          # calculate pop, gold and food
          self.province_pop = []
          self.province_gold = []
          self.province_food = []

          for i in list(range(0,41)) :
              self.province_pop.append((self.province_data_array[i][6] + self.province_data_array[i][7]*(2**8))*100)
              self.province_gold.append(self.province_data_array[i][0] + self.province_data_array[i][1]*(2**8))
              self.province_food.append(self.province_data_array[i][2] + self.province_data_array[i][3]*(2**8) + self.province_data_array[i][4]*(2**16))

          # merge the dataframes
          self.province_gold_array = pd.DataFrame(self.province_gold, columns=['Gold'])
          self.province_food_array = pd.DataFrame(self.province_food, columns=['Food'])
          self.province_pop_array = pd.DataFrame(self.province_pop, columns=['Pop'])

          self.province_data_df = pd.DataFrame(self.province_data)

          return pd.concat([
                  self.province_pop_array,
                  self.province_gold_array,
                  self.province_food_array,
                  self.province_data_df.iloc[:, 8],
                  self.province_data_df.iloc[:, 14:20]
                  ],
                  axis=1)
  ```
  </details>

  ```python
  rtk2 = Rtk2()

  save = rtk2.dataload('path', 15) # the parameter lord('15') doesn't work yet
  save.head()
  ```

  > Pop   Gold     Food   8   14   15   16  17  18  19  
  > 0  274400   4080     4364   3    9   75    4   4   1  27  
  > 1  225900  29450  2700000  15   50  100   92   0   2  62  
  > 2  253300  29950  2700000  15  100  100  100  28   4  70  
  > 3  198500  30000  2699000  15  100  100  100  79   0  66  
  > 4  268000  30000  2700000  15  100  100  100  16   1  48  


## [Get Provinces' Data from the Save File (2019.07.23)](#list)

- Call each province's data of population, gold, food and so on from a save file

  <details>
    <summary>Codes : RTK2_Province.py</summary>

  ```python
  # province_offset_data - from Offset.py (2019.07.22)
  province_offset_init = []
  province_offset_data = []

  for i in list(range(0,41)) :
      province_offset_init.append(11668 + 35*i)
      province_offset_data.append(list(range(province_offset_init[i], province_offset_init[i]+35)))
  ```

  ```python
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
  ```
  > [[182, 0, 8, 1, 0, 0, 240, 9, 3, 255, 128, 48, 255, 255, 7, 79, 4, 4, 1, 34, 8, 1, 55, 0, 6, 0, 0, 196, 45, 217, 0, 0, 0, 0, 0],  
  > [20, 10, 172, 74, 4, 0, 20, 9, 3, 255, 128, 50, 255, 2, 56, 100, 52, 0, 2, 64, 221, 0, 67, 0, 5, 0, 0, 150, 46, 11, 26, 12, 5, 0, 0],  
  > [48, 117, 96, 54, 42, 0, 61, 9, 15, 255, 0, 0, 255, 255, 100, 99, 100, 33, 4, 55, 174, 0, 73, 0, 4, 1, 0, 0, 0, 182, 4, 0, 0, 0, 0]]

  ```python
  # test : gold
  province_gold = []

  for i in list(range(0,41)) :
      province_gold.append(province_data[i][0] + province_data[i][1]*256)

  print(province_gold)
  ```
  > [182, 2580, 30000, 30000, 30000, 7139, 30000, 1783, 29880, 30000, 29988, 30000, 130, 73, 51, 339, 30000, 0, 30000, 11841, 311, 2542, 12033, 0, 100, 100, 100, 605, 3697, 8908, 30000, 22452, 30000, 6341, 7482, 3649, 2528, 574, 4451, 8050, 12206]

  ```python
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
  ```
  </details>

  > Province Pop             Gold    Food            Rate Horses Loy Land Flood Forts  
  > 1        254400          182     264     34 4 79 7 4 1  
  > 2        232400          2580    281260          64 0 100 56 52 2  
  > 3        236500          30000   2766432         55 33 99 100 100 4  
  > 4        179300          30000   1732260         46 82 99 93 96 0  
  > 5        246800          30000   2666060         57 19 96 100 100 1  
  > 6        499500          7139    233937          50 42 98 79 64 3  
  > 7        269800          30000   2730580         37 85 94 100 100 3  
  > 8        173600          1783    329476          41 49 100 83 83 2  
  > 9        276300          29880   2694902         30 39 95 47 79 2  
  > 10       1010800         30000   3000000         33 83 96 100 100 6  


## [Get Provinces Data's Offset from the Save File (2019.07.22)](#list)

- Make offset locations' list before call the save data

  #### `RTK2_Province_Offset.py`

  ```python
  """
  the initial data offset addresses of the each province (hexadecimal)
  1 - 2d94
  2 - 2db7   
  3 - 2dda
  ……
  41 - 330c
  """
  ```

  ```python
  # 각 영토별 데이터는 35바이트 단위임을 확인
  int('2db7', 16) - int('2d94', 16)
  int('2dda', 16) - int('2db7', 16)
  ```
  > 35  
  > 35

  <details>
    <summary>Codes and Results</summary>

  ```python
  # 영토별 첫번째 값의 offset 위치를 10진수로 확인
  0x2d94
  0x330c
  type(0x330c) # 이 자체로 int type
  ```
  > 11668  
  > 13068  
  > int

  ```python
  # 35바이트 간격 리스트 생성하기(*꼭 16진수로 할 필요없다)
  province_offset_init = [11668]
  for i in list(range(1,41)) :
      province_offset_init.append(province_offset_init[0] + 35*i)

  print(province_offset_init)
  len(province_offset_init)
  ```
  > [11668, 11703, 11738, 11773, 11808, 11843, 11878, 11913, 11948, 11983, 12018, 12053, 12088, 12123, 12158, 12193, 12228, 12263, 12298, 12333, 12368, 12403, 12438, 12473, 12508, 12543, 12578, 12613, 12648, 12683, 12718, 12753, 12788, 12823, 12858, 12893, 12928, 12963, 12998, 13033, 13068]  
  > 41

  ```python
  # offset : gold
  province_offset_gold = []
  for i in list(range(0,41)) :
      province_offset_gold.append([province_offset_init[i], province_offset_init[i]+1])

  print(province_offset_gold)
  # offset : food
  # offset : loyalty
  # an so on …… 
  ```
  > [[11668, 11669], [11703, 11704], [11738, 11739], [11773, 11774], [11808, 11809], [11843, 11844], [11878, 11879], [11913, 11914], [11948, 11949], [11983, 11984], [12018, 12019], [12053, 12054], [12088, 12089], [12123, 12124], [12158, 12159], [12193, 12194], [12228, 12229], [12263, 12264], [12298, 12299], [12333, 12334], [12368, 12369], [12403, 12404], [12438, 12439], [12473, 12474], [12508, 12509], [12543, 12544], [12578, 12579], [12613, 12614], [12648, 12649], [12683, 12684], [12718, 12719], [12753, 12754], [12788, 12789], [12823, 12824], [12858, 12859], [12893, 12894], [12928, 12929], [12963, 12964], [12998, 12999], [13033, 13034], [13068, 13069]]

  ```python
  # province_offset_data (more efficient way)
  province_offset_data = []
  for i in list(range(0,41)) :
      province_offset_data.append(list(range(province_offset_init[i], province_offset_init[i]+35)))

  print(province_offset_data[0:2])
  ```
  > [[11668, 11669, 11670, 11671, 11672, 11673, 11674, 11675, 11676, 11677, 11678, 11679, 11680, 11681, 11682, 11683, 11684, 11685, 11686, 11687, 11688, 11689, 11690, 11691, 11692, 11693, 11694, 11695, 11696, 11697, 11698, 11699, 11700, 11701, 11702], [11703, 11704, 11705, 11706, 11707, 11708, 11709, 11710, 11711, 11712, 11713, 11714, 11715, 11716, 11717, 11718, 11719, 11720, 11721, 11722, 11723, 11724, 11725, 11726, 11727, 11728, 11729, 11730, 11731, 11732, 11733, 11734, 11735, 11736, 11737]]

  ```python
  # province_offset_data (final)
  province_offset_init = []
  province_offset_data = []
  for i in list(range(0,41)) :
      province_offset_init.append(11668 + 35*i)
      province_offset_data.append(list(range(province_offset_init[i], province_offset_init[i]+35)))

  print(province_offset_init)
  print(province_offset_data[0:2])
  ```
  > [11668, 11703, 11738, 11773, 11808, 11843, 11878, 11913, 11948, 11983, 12018, 12053, 12088, 12123, 12158, 12193, 12228, 12263, 12298, 12333, 12368, 12403, 12438, 12473, 12508, 12543, 12578, 12613, 12648, 12683, 12718, 12753, 12788, 12823, 12858, 12893, 12928, 12963, 12998, 13033, 13068]  
  > [[11668, 11669, 11670, 11671, 11672, 11673, 11674, 11675, 11676, 11677, 11678, 11679, 11680, 11681, 11682, 11683, 11684, 11685, 11686, 11687, 11688, 11689, 11690, 11691, 11692, 11693, 11694, 11695, 11696, 11697, 11698, 11699, 11700, 11701, 11702], [11703, 11704, 11705, 11706, 11707, 11708, 11709, 11710, 11711, 11712, 11713, 11714, 11715, 11716, 11717, 11718, 11719, 11720, 11721, 11722, 11723, 11724, 11725, 11726, 11727, 11728, 11729, 11730, 11731, 11732, 11733, 11734, 11735, 11736, 11737]]
  </details>