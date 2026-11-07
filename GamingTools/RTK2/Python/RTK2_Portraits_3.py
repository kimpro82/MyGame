"""RTK2 > Get Portraits from KAODATA.DAT (Trial 3)

Date   : 2026.11.07
Author : kimpro82

Each group of three bytes stores one bitplane byte per color-index bit. Matching
bit positions across the three bytes form eight palette indices. The decoded
64-by-40 portraits are arranged into a sheet and colored with the palette in
RTK2_Palette.json.

History:
    2026.11.07 : Added configurable palettes and image formats, plus row-based portrait
                layout. GIF is the default output format.

Usage (run from GamingTools/RTK2/Python)::

    python RTK2_Portraits_3.py \
        PORTRAITS_PER_ROW=15 PALETTE_NAME=palette_rtk2_3 \
        IMAGE_FORMAT=gif SAVE_PATH=Images/RTK2_Portraits3.gif
"""

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
    """Read the binary portrait data from disk.

    Args:
        path: Path to the KAODATA.DAT file.

    Returns:
        The file contents as bytes.

    Raises:
        OSError: If the file cannot be opened or read.
    """
    return path.read_bytes()


def read_palette_file(path=PALETTE_PATH, palette_name=PALETTE_NAME):
    """Load a named RGB palette from the palette JSON file.

    Args:
        path: Path to the JSON palette file.
        palette_name: JSON key containing the ordered RGB colors.

    Returns:
        A list of RGB color triplets, indexed by decoded pixel value.

    Raises:
        OSError: If the palette file cannot be opened.
        json.JSONDecodeError: If the file is not valid JSON.
        ValueError: If ``palette_name`` is not present in the file.
    """
    with path.open("r", encoding="utf-8") as palette_file:
        palettes = json.load(palette_file)
    if palette_name not in palettes:
        raise ValueError(f"Palette '{palette_name}' was not found in {path}")
    return palettes[palette_name]


def extract_3_bit_palette_indices(byte_data):
    """Decode 3-bit color indices from groups of three bitplane bytes.

    Bits are read from most significant to least significant. For each bit
    position, Plane 2 supplies the high index bit and Plane 0 the low bit.

    Args:
        byte_data: Binary data arranged as repeated Plane 0, Plane 1, Plane 2
            byte groups.

    Returns:
        Eight palette indices per 3-byte group, each in the range 0 through 7.

    Raises:
        ValueError: If the data ends with an incomplete 3-byte group.
    """
    if len(byte_data) % 3:
        raise ValueError("3BPP data must contain complete 3-byte plane groups")

    palette_indices = []
    for offset in range(0, len(byte_data), 3):
        # Each byte contributes one bit to each of the eight adjacent pixels.
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
    """Arrange decoded portraits in a row-major sheet and save the image.

    Args:
        palette_indices: Flat sequence of decoded 3-bit palette indices.
        palette: Ordered RGB colors used to convert indices to pixels.
        portraits_per_row: Number of 64-by-40 portraits in each sheet row.
        path: Destination path. Its parent directories are created if needed.
        image_format: Output format: ``gif``, ``png``, or ``jpg``.

    Raises:
        ValueError: If the row count is non-positive or the pixel count does
            not contain complete portraits.
        OSError: If the output image cannot be written.
    """
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
    """Parse optional command-line settings written as KEY=VALUE arguments.

    Supported keys are ``PORTRAITS_PER_ROW``, ``PALETTE_NAME``,
    ``IMAGE_FORMAT``, and ``SAVE_PATH``. Missing values retain their defaults.
    ``IMAGE_FORMAT`` accepts ``gif``, ``png``, ``jpg``, or ``jpeg``; JPEG is
    normalized to ``jpg``. If the save path is omitted, its extension follows
    the selected format. An explicitly supplied extension must match the format.

    Args:
        arguments: Command-line arguments, excluding the program name.

    Returns:
        A dictionary containing the validated row count, palette key, output
        format, and destination path.

    Raises:
        ValueError: If an argument is malformed, duplicated, unknown, or has
            an invalid value.
    """
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