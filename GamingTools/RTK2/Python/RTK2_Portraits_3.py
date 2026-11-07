"""Decode RTK2 portraits from the 3-bit-plane KAODATA.DAT format."""

from pathlib import Path

from PIL import Image


BASE_DIR = Path(__file__).resolve().parent
LOAD_PATH = BASE_DIR / "Data" / "KAODATA.DAT"
SAVE_PATH = BASE_DIR / "Images" / "RTK2_Portraits3.gif"
PORTRAIT_WIDTH = 64
PORTRAIT_HEIGHT = 40
PORTRAITS_PER_ROW = 15

PALETTE = [
    (47, 31, 0),
    (31, 63, 127),
    (175, 63, 31),
    (191, 127, 79),
    (63, 111, 31),
    (63, 127, 143),
    (255, 175, 127),
    (207, 207, 175),
]


def read_data_file(path=LOAD_PATH):
    """Read the binary portrait data."""
    return path.read_bytes()


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


def save_image(palette_indices, path=SAVE_PATH):
    """Arrange 64-by-40 portraits in rows and save the portrait sheet."""
    portrait_size = PORTRAIT_WIDTH * PORTRAIT_HEIGHT
    if len(palette_indices) % portrait_size:
        raise ValueError("Pixel count must contain complete 64-by-40 portraits")

    portrait_count = len(palette_indices) // portrait_size
    row_count = (portrait_count + PORTRAITS_PER_ROW - 1) // PORTRAITS_PER_ROW
    image = Image.new(
        "RGB",
        (PORTRAIT_WIDTH * PORTRAITS_PER_ROW, PORTRAIT_HEIGHT * row_count),
    )

    for portrait_index in range(portrait_count):
        start = portrait_index * portrait_size
        end = start + portrait_size
        portrait = Image.new("RGB", (PORTRAIT_WIDTH, PORTRAIT_HEIGHT))
        portrait.putdata([PALETTE[index] for index in palette_indices[start:end]])
        position = (
            (portrait_index % PORTRAITS_PER_ROW) * PORTRAIT_WIDTH,
            (portrait_index // PORTRAITS_PER_ROW) * PORTRAIT_HEIGHT,
        )
        image.paste(portrait, position)

    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)


if __name__ == "__main__":
    data = read_data_file()
    palette_indices = extract_3_bit_palette_indices(data)
    save_image(palette_indices)
    print(f"Saved {len(palette_indices)} pixels to {SAVE_PATH}")