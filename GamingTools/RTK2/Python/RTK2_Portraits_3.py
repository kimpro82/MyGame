"""Decode RTK2 portraits from the 3-bit-plane KAODATA.DAT format."""

import json
from pathlib import Path
import sys

from PIL import Image


BASE_DIR = Path(__file__).resolve().parent
LOAD_PATH = BASE_DIR / "Data" / "KAODATA.DAT"
PALETTE_PATH = BASE_DIR / "RTK2_Palette.json"
PALETTE_NAME = "palette_rtk2_3"
SAVE_PATH = BASE_DIR / "Images" / "RTK2_Portraits3.gif"
IMAGE_FORMAT = "gif"
PORTRAIT_WIDTH = 64
PORTRAIT_HEIGHT = 40
PORTRAITS_PER_ROW = 15


def read_data_file(path=LOAD_PATH):
    """Read the binary portrait data."""
    return path.read_bytes()


def read_palette_file(path=PALETTE_PATH, palette_name=PALETTE_NAME):
    """Read the RGB palette used by the portrait data."""
    with path.open("r", encoding="utf-8") as palette_file:
        palettes = json.load(palette_file)
    if palette_name not in palettes:
        raise ValueError(f"Palette '{palette_name}' was not found in {path}")
    return palettes[palette_name]


def extract_3_bit_palette_indices(byte_data):
    """Recombine each group of three bit-plane bytes into eight pixel indices."""
    if len(byte_data) % 3:
        raise ValueError("3BPP data must contain complete 3-byte plane groups")

    palette_indices = []
    for offset in range(0, len(byte_data), 3):
        plane_0, plane_1, plane_2 = byte_data[offset : offset + 3]
        for bit_position in range(7, -1, -1):
            bit_0 = (plane_0 >> bit_position) & 1
            bit_1 = (plane_1 >> bit_position) & 1
            bit_2 = (plane_2 >> bit_position) & 1
            palette_indices.append((bit_2 << 2) | (bit_1 << 1) | bit_0)

    return palette_indices


def save_image(
    palette_indices,
    palette,
    portraits_per_row=PORTRAITS_PER_ROW,
    path=SAVE_PATH,
    image_format=IMAGE_FORMAT,
):
    """Arrange 64-by-40 portraits in rows and save the portrait sheet."""
    if portraits_per_row <= 0:
        raise ValueError("PORTRAITS_PER_ROW must be a positive integer")

    portrait_size = PORTRAIT_WIDTH * PORTRAIT_HEIGHT
    if len(palette_indices) % portrait_size:
        raise ValueError("Pixel count must contain complete 64-by-40 portraits")

    portrait_count = len(palette_indices) // portrait_size
    row_count = (portrait_count + portraits_per_row - 1) // portraits_per_row
    image = Image.new(
        "RGB",
        (PORTRAIT_WIDTH * portraits_per_row, PORTRAIT_HEIGHT * row_count),
    )

    for portrait_index in range(portrait_count):
        start = portrait_index * portrait_size
        end = start + portrait_size
        portrait = Image.new("RGB", (PORTRAIT_WIDTH, PORTRAIT_HEIGHT))
        portrait.putdata([tuple(palette[index]) for index in palette_indices[start:end]])
        position = (
            (portrait_index % portraits_per_row) * PORTRAIT_WIDTH,
            (portrait_index // portraits_per_row) * PORTRAIT_HEIGHT,
        )
        image.paste(portrait, position)

    path.parent.mkdir(parents=True, exist_ok=True)
    pil_format = {"gif": "GIF", "png": "PNG", "jpg": "JPEG"}[image_format]
    image.save(path, format=pil_format)


def parse_key_value_args(arguments):
    """Parse optional portrait layout, palette, output format, and path values."""
    options = {
        "PORTRAITS_PER_ROW": PORTRAITS_PER_ROW,
        "PALETTE_NAME": PALETTE_NAME,
        "SAVE_PATH": SAVE_PATH,
        "IMAGE_FORMAT": IMAGE_FORMAT,
    }
    provided_keys = set()

    for argument in arguments:
        key, separator, value = argument.partition("=")
        if not separator or not value:
            raise ValueError(f"Expected KEY=VALUE, got '{argument}'")
        if key not in options:
            raise ValueError(f"Unknown option '{key}'")
        if key in provided_keys:
            raise ValueError(f"Option '{key}' was provided more than once")
        options[key] = value
        provided_keys.add(key)

    try:
        options["PORTRAITS_PER_ROW"] = int(options["PORTRAITS_PER_ROW"])
    except ValueError:
        raise ValueError("PORTRAITS_PER_ROW must be a positive integer") from None
    if options["PORTRAITS_PER_ROW"] <= 0:
        raise ValueError("PORTRAITS_PER_ROW must be a positive integer")

    image_format = str(options["IMAGE_FORMAT"]).lower()
    if image_format == "jpeg":
        image_format = "jpg"
    if image_format not in ("gif", "png", "jpg"):
        raise ValueError("IMAGE_FORMAT must be gif, png, jpg, or jpeg")
    options["IMAGE_FORMAT"] = image_format

    suffix = ".jpg" if image_format == "jpg" else f".{image_format}"
    save_path = Path(options["SAVE_PATH"])
    if "SAVE_PATH" not in provided_keys:
        save_path = SAVE_PATH.with_suffix(suffix)
    elif not save_path.suffix:
        save_path = save_path.with_suffix(suffix)
    else:
        valid_suffixes = {suffix, ".jpeg"} if image_format == "jpg" else {suffix}
        if save_path.suffix.lower() not in valid_suffixes:
            raise ValueError(f"SAVE_PATH extension must match IMAGE_FORMAT ({image_format})")
    options["SAVE_PATH"] = save_path
    return options


if __name__ == "__main__":
    try:
        options = parse_key_value_args(sys.argv[1:])
        data = read_data_file()
        palette = read_palette_file(palette_name=options["PALETTE_NAME"])
        palette_indices = extract_3_bit_palette_indices(data)
        save_image(
            palette_indices,
            palette,
            portraits_per_row=options["PORTRAITS_PER_ROW"],
            path=options["SAVE_PATH"],
            image_format=options["IMAGE_FORMAT"],
        )
    except ValueError as error:
        raise SystemExit(f"Error: {error}") from None
    print(
        f"Saved {len(palette_indices)} pixels as {options['IMAGE_FORMAT'].upper()} "
        f"to {options['SAVE_PATH']}"
    )