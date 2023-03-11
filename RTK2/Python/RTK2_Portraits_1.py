# RTK2 : Get Portraits from KAODATA.DAT
# 2023.03.09

import os
from PIL import Image

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

def Extract3Bits(data):
    pixels = []
    for byte in data:
        for i in range(8):                                                      # Iterate over 8 bits (== 1 byte)
            pixel_value = (byte >> (3*i)) & 0b111                               # Extract 3-bit data and guarantee always between 0 and 7 by adding `& 0b111`
            pixels.append(pixel_value)
    if test:
        print("pixels : ", pixels[:5])                                          # OK : [5, 2, 1, 0, 0]
    return pixels

def ConvertColors(pixels):
    image_data = [palette[pixel_value] for pixel_value in pixels]
    if test:
        print("converted colors : ", image_data[:5])                            # OK : [(255, 255, 0), (255, 0, 0), (255, 255, 255), (0, 0, 0), (0, 0, 0)]
    return image_data

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