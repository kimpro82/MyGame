"""
RTK2 : Get Portraits from KAODATA.DAT (Trial 2)
2024.08.05
"""

import os
import json
from PIL import Image   # Pillow

# Parameters
IS_TEST         = True  # True : Test Mode
LOAD_PATH       = "./KAODATA.DAT"
PALETTE_PATH    = "./RTK2_Palette.json"
PALETTE_NAME    = "palette_rtk2_3"
SAVE_PATH       = "./Images/RTK2_Portraits2.gif"
TEST_PATH       = "./Images/RTK2_Portraits2_Test.gif"
WIDTH           = 64


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
                    print(
                        f"  data[{i}] : {chr(_data[i])} {_data[i]:3d} {bin(_data[i])}"
                    )
                print("  ……")
            return _data
    else:
        print("  There's no target file.")
        exit()


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
                print(
                    f"  data[{index}] : {byte:3d} {bin(byte):10s} {bit_list[-8:]}"
                )
            elif index == 3:
                print("  ……")

    # Extract 3-bit palette indices
    palette_indices = []
    for index in range(0, len(bit_list), 3):
        if index + 2 < len(bit_list):
            palette_index = (bit_list[index] << 2) | (
                bit_list[index + 1] << 1) | bit_list[index + 2]
            palette_indices.append(palette_index)
            if IS_TEST:
                if index < 24:
                    print(
                        f"  palette_index[{int(index/3)}] : {bit_list[index:index+3]} {bin(palette_index):5s} {palette_index}"
                    )
                elif index == 24:
                    print("  ……")
    return palette_indices


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
            print(
                f"  converted_color[{i}] : {_palette_indices[i]} {_rgb_colors[i]}"
            )
        print("  ……")
    return _rgb_colors


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


# Run
if __name__ == "__main__":
    print("Reading data file ……")
    data = read_data_file(LOAD_PATH)

    print("Reading palette file ……")
    palette = read_palette_file(PALETTE_PATH)

    print("Extracting 3-bit palette indices ……")
    extracted_palette_indices = extract_3_bit_palette_indices(data)

    print("Converting palette indices to RGB ……")
    converted_colors = convert_colors_to_rgb(extracted_palette_indices,
                                             palette)

    print("Saving image ……")
    save_image(converted_colors)
