# Image Cropper
# 2023.03.26 ~ 28


# Libraries
from PIL import Image                                       # PIL; Python Imaging Library
import json                                                 # json.load(); call coordinates information for cropping from the external JSON file
import os                                                   # os.path.*, os.getcwd(), os.makedirs(); deal with paths in various ways
import sys                                                  # sys.argv; read "test" arguement from the terminal command or batchfile
import pprint                                               # pprint.pprint(); print multi-line data like JSON with line replacement


# Global variables
test = False


# Find if test mode
def FindIfTest():

    global test                                             # must be declared in each udf
    args = sys.argv

    if len(args) >= 2 and args[1] == "test":
        test = True
        print("<Test Mode>")

    return test


# Read `Cropper_Setting.json` that contains customized patterns and their coordinate information and paths
def ReadJson():

    global test

    with open('./Cropper_Setting.json', 'r') as f:
        params = json.load(f)
    coordinates = params["coordinates"]
    path = params["path"]

    if test:
        print("\n- ReadJson()")
        pprint.pprint(coordinates)                          # ok
        print(path)                                         # ok

    return coordinates, path


# Get the image file list from the target directory
def GetImageFileList(path):

    imageExtensions = ['.jpg', '.jpeg', '.png', '.bmp']     # can be added more
    imageFiles = []
    cwdImages = os.path.join(os.getcwd(), path[1])

    for file_name in os.listdir(cwdImages):
        ext = os.path.splitext(file_name)[-1].lower()
        if ext in imageExtensions:
            imageFiles.append(os.path.join(cwdImages, file_name))

    if test:
        print("\n- GetImageFileList()")
        print(cwdImages)                                    # ok
        pprint.pprint(imageFiles)                           # ok; including path

    return imageFiles


# Get the path for saving cropped image file
def GetSavePath(imageFile, path):

    croppedImageFile = os.path.join(os.getcwd(), path[2], os.path.basename(imageFile))

    return croppedImageFile


# Find if the same name's file already exists and determine if overwrite in `CropImages()`
def FindExist(croppedImageFile):

    overwrite = "y"

    if os.path.exists(croppedImageFile):
        while True:
            overwrite = input(f"{os.path.basename(croppedImageFile)} already exists. Do you want to overwrite it? (y/n) ")
            if overwrite.lower() == "y":
                break
            elif overwrite.lower() == "n":
                break
            else:
                print("Invalid input. Please enter y or n.")

    return overwrite


# Get option from image file names in `CropImages()`
def GetOption(imageFile):

    global test
    option = ""
    imageFileName, ext = os.path.splitext(imageFile)        # `ext` won't be used
    underscoreIndex = imageFileName.rfind("_")              # find the string after the last "_"

    if underscoreIndex > 0:
        option, ext = os.path.splitext(imageFileName[underscoreIndex+1:])
        if option not in coordinates:
            option = "no valid option"

    if test:
        print(f"({option})".ljust(20), end="")

    return option


# Crop and save images
def CropImages(imageFiles, coordinates, path):

    global test

    if test:
        print("\n- CropImages()")

    # make a new directory to save cropped image files if not exists (do not need `if` statement)
    os.makedirs(os.path.join(os.getcwd(), path[2]), exist_ok=True)

    for imageFile in imageFiles:

        croppedImageFile = GetSavePath(imageFile, path)
        overwrite = FindExist(croppedImageFile)
        # if no same name's file or allowed to be overwrited

        if overwrite.lower() == "y":
            option = GetOption(imageFile)
            image = Image.open(imageFile)
        
            if option in coordinates:
                cropBox = coordinates[option]
                imageCropped = image.crop(cropBox)
                imageCropped.save(croppedImageFile)

            else:
                image.save(croppedImageFile)                # the same with the original image when no option
            print("File saved. :", croppedImageFile)

        else:
            print("File not saved. :", croppedImageFile)


# Run
if __name__ == "__main__":

    FindIfTest()                                            # control global variable `test`
    coordinates, path = ReadJson()
    imageFiles = GetImageFileList(path)
    CropImages(imageFiles, coordinates, path)
    print("Works ended.")