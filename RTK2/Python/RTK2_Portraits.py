# RTK2 : Get Portraits from KAODATA.DAT
# 2023.03.07

import os
from PIL import Image

test = True                                                 # True : Test Mode


# 0. Read the file if exists

path = "C:\Game\KOEI\RTK2\KAODATA.DAT"
if (os.path.isfile(path)):
    with open(path, 'rb') as f:
        data = f.read()
    if test:
        print(data[:10])                                    # OK
else:
    print("There's no target file.")
    exit()


# 1. Slicing the data



chunks = [data[i:i+3] for i in range(0, 64 * 80, 3)]
# chunks = [data[i:i+3] for i in range(0, len(data), 3)]
if test:
    print(chunks[:5])                                       # OK
    print(int(chunks[0]))


# 2. Get portraits

# Each general's portrait consists of (64, 80) size

# gif_frames = []
# for chunk in chunks:
#     # 각 바이트를 픽셀값으로 변환
#     pixels = [int(b) for b in chunk]
#     print(pixels[:5])
#     # 이미지 생성
#     img = Image.new('1', (3, 1), 0)
#     img.putdata(pixels)
#     # GIF 프레임 추가
#     gif_frames.append(img)

# # # GIF 파일 저장
# gif_frames[0].save('./images/RTK2_Portraits.gif', format='GIF', append_images=gif_frames[1:], save_all=True, duration=100, loop=0)