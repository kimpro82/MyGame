"""
RTK2 ERP / Extract and Arrange the Ruler, Province, and General Data from the Save File.

Author : kimpro82
Date: 2025.07.06

<UDFs>
- read_binary_file(filename): Reads the file in binary mode and returns the byte data
- extract_general_data(data): Extracts general (officer) data and returns a DataFrame
- extract_province_data(data, generals_df): Extracts province data and returns a DataFrame (requires general data for governor name)
- extract_ruler_data(data, provinces_df, generals_df): Extracts ruler data and returns a DataFrame (requires province and general data)
- arrange_province_data(rulers_df, provinces_df): Arranges provinces for each ruler by traversing the province linked list (next_prov_idx)
- arrange_general_data(arranged_provinces_df, generals_df): Arranges generals for each province by traversing the general linked list (next_gen_idx)
- save_dataframes_to_csv(data_frames, save_dir, sep): Saves DataFrames to CSV files in the specified directory with the given separator
"""


import os
import pandas as pd


def read_binary_file(filename):
    """Read the specified file in binary mode and return the byte data."""

    with open(filename, "rb") as f:
        data = f.read()

    return data


def extract_general_data(data, start=32, length=43, count=255):
    """
    Extract general (officer) data from the binary file.
    Returns a DataFrame with one row per general.
    """

    generals = []
    for i in range(count):
        offset = start + i * length
        chunk = data[offset:offset+length]
        general = {
            "general_idx": int((offset + 9) / 43),
            "next_gen_idx": int(max((chunk[0] + chunk[1] * 256 - 88)/43, -1)),  # Next general in province (linked list)
            "name": chunk[28:43].split(b'\x00')[0].decode('cp949', errors='ignore'),
            "int": chunk[4],
            "war": chunk[5],
            "cha": chunk[6],
            "fai": chunk[7],
            "vir": chunk[8],
            "amb": chunk[9],
            "ruler_idx": chunk[10],  # Ruler index this general belongs to
            "loy": chunk[11],
            "exp": chunk[12],
            "syn": chunk[15],
            "soldiers": chunk[18] + chunk[19] * 256,
            "weapons": chunk[20] + chunk[21] * 256,
            "trainning": chunk[22],
            "birth": chunk[25],
            "face": chunk[26] + chunk[27] * 256,
        }
        # if general["birth"] >= 0:
        generals.append(general)

    df = pd.DataFrame(generals)

    return df


def extract_province_data(data, generals_df, start=11660, length=35, count=41):
    """
    Extract province data from the binary file.
    Returns a DataFrame with one row per province.
    Each province contains a linked list pointer (next_prov_idx) and a governor index.
    """

    provinces = []
    for i in range(count):
        offset = start + i * length
        chunk = data[offset:offset+length]
        ruler_idx = chunk[16]
        governor_idx = int(max((chunk[2] + chunk[3] * 256 - 88) / 43, -1))
        province = {
            "prov_idx": i + 1,  # 1-based province index
            "next_prov_idx": int(max((chunk[0] + chunk[1] * 256 - 21 -11660)/35, -1)),  # Next province in ruler's list
            "governor_idx": governor_idx,  # Index of the governor general
            "governor": generals_df.iloc[governor_idx]["name"] if ruler_idx >= 0 else "",
            "gold": chunk[8] + chunk[9] * 256,
            "food": chunk[10] + chunk[11] * 256 + chunk[12] * 65536,
            "pop": (chunk[14] + chunk[15] * 256) * 100,
            "ruler_idx": ruler_idx,  # Ruler index who owns this province
            "loy" : chunk[23],
            "land": chunk[22],
            "flood" : chunk[24],
            "horses" : chunk[25],
            "forts" : chunk[26],
            "rate" : chunk[27],
            "merch" : bool((chunk[19] % 4) > 0),
            "state" : chunk[34],
        }
        provinces.append(province)

    return pd.DataFrame(provinces)


def extract_ruler_data(data, provinces_df, generals_df, start=11004, length=41, count=16):
    """
    Extract ruler data from the binary file.
    Returns a DataFrame with one row per ruler.
    Each ruler contains a capital province index and summary stats.
    """

    rulers = []
    for i in range(count):
        offset = start + i * length
        chunk = data[offset:offset+length]
        ruler_idx = int(max((chunk[0] + chunk[1] * 256 -88)/43, -1))
        advisor_idx = int(max((chunk[4] + chunk[5] * 256 - 88)/43, -1))
        ruler_idx = int(max((chunk[0] + chunk[1] * 256 -88)/43, -1))
        capital_idx = int((chunk[2] + chunk[3] * 256 - 21 -11660)/35)  # Capital province index
        advisor_idx = int(max((chunk[4] + chunk[5] * 256- 88)/43, -1))
        gold_sum = provinces_df[provinces_df["ruler_idx"] == ruler_idx]["gold"].sum()
        food_sum = provinces_df[provinces_df["ruler_idx"] == ruler_idx]["food"].sum()
        pop_sum = provinces_df[provinces_df["ruler_idx"] == ruler_idx]["pop"].sum()
        soldiers_sum = generals_df[generals_df["ruler_idx"] == ruler_idx]["soldiers"].sum()
        generals_cnt = generals_df[generals_df["ruler_idx"] == ruler_idx].shape[0]
        ruler = {
            "ruler_idx": ruler_idx,
            "ruler_name": generals_df.iloc[ruler_idx]["name"] if ruler_idx >= 0 else "",
            "capital_idx": capital_idx if ruler_idx >= 0 else "",
            "advisor_idx": advisor_idx,
            "advisor_name": generals_df.iloc[advisor_idx]["name"] if advisor_idx >= 0 else "",
            "trust": chunk[6],
            "gold_sum": gold_sum,
            "food_sum": food_sum,
            "pop_sum": pop_sum,
            "soldiers_sum": soldiers_sum,
            "generals_cnt": generals_cnt,
        }
        rulers.append(ruler)

    return pd.DataFrame(rulers)


def arrange_province_data(rulers_df, provinces_df):
    """
    For each ruler, traverse the province linked list starting from capital_idx.
    Collect all province rows in order for each ruler. After all rulers, add remaining unowned provinces (ruler_idx == 255).
    Returns a DataFrame with the arranged province order.
    """

    arranged_rows = []
    visited = set()
    for _, ruler in rulers_df.iterrows():
        prov_idx = ruler["capital_idx"]
        while prov_idx != -1 and prov_idx not in visited:
            visited.add(prov_idx)
            prov_row = provinces_df[provinces_df["prov_idx"] == prov_idx]
            if not prov_row.empty:
                row = prov_row.iloc[0].to_dict()
                row["ruler_idx"] = ruler["ruler_idx"]
                row["ruler_name"] = ruler["ruler_name"]
                arranged_rows.append(row)
                prov_idx = row["next_prov_idx"]
            else:
                break

    # Add unowned provinces (ruler_idx == 255) that were not visited
    empty = provinces_df[(provinces_df["ruler_idx"] == 255) & (~provinces_df["prov_idx"].isin(visited))]
    for _, row in empty.iterrows():
        row_dict = row.to_dict()
        row_dict["ruler_idx"] = 255
        row_dict["ruler_name"] = "Empty"
        arranged_rows.append(row_dict)

    arranged_provinces_df = pd.DataFrame(arranged_rows)

    return arranged_provinces_df


def arrange_general_data(arranged_provinces_df, generals_df):
    """
    For each province in arranged_provinces_df, traverse the general linked list starting from governor_idx.
    Collect all general rows in order for each province.
    Returns a DataFrame with the arranged general order.
    """

    arranged_rows = []
    for _, province in arranged_provinces_df.iterrows():
        gen_idx = province["governor_idx"]
        visited = set()
        while gen_idx != -1 and gen_idx not in visited:
            visited.add(gen_idx)
            gen_row = generals_df[generals_df["general_idx"] == gen_idx]
            if not gen_row.empty:
                row = gen_row.iloc[0].to_dict()
                row["prov_idx"] = province["prov_idx"]
                row["prov_governor"] = province["governor"]
                row["prov_ruler"] = province["ruler_name"]
                arranged_rows.append(row)
                gen_idx = row["next_gen_idx"]
            else:
                break

    arranged_generals_df = pd.DataFrame(arranged_rows)

    return arranged_generals_df


def save_dataframes_to_csv(data_frames, save_dir="./Data", sep=","):
    """
    Save multiple DataFrames to CSV files in the specified directory. Create the directory if it does not exist.
    Args:
        dataframes (dict): {filename(str): dataframe(pd.DataFrame)}
        save_dir (str): Directory to save CSV files.
        sep (str): Delimiter to use (default: ','). Use '\t' for tab-separated.
    """

    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    for name, df in data_frames.items():
        path = os.path.join(save_dir, f"{name}.csv")
        df.to_csv(path, index=False, sep=sep)

    print(f"DataFrames have been saved to {save_dir} as CSV files (sep='{sep}').")

    return


if __name__ == "__main__":
    # Target filename constant
    FILENAME = "SC5TEST"

    # Extract general, province, and ruler data
    binary_data = read_binary_file(FILENAME)
    general_df = extract_general_data(binary_data)
    province_df = extract_province_data(binary_data, general_df)
    ruler_df = extract_ruler_data(binary_data, province_df, general_df)

    # Arrange province and general data by linked list order
    arranged_province_df = arrange_province_data(ruler_df, province_df)
    arranged_general_df = arrange_general_data(arranged_province_df, general_df)

    # Print sample outputs
    print("Ruler DataFrame (first 5 rows):")
    print(ruler_df.head(), "\n")
    print("Arranged Province DataFrame (first 5 rows):")
    print(arranged_province_df.head(), "\n")
    print("Arranged General DataFrame (first 5 rows):")
    print(arranged_general_df.head(), "\n")

    # Save DataFrames to CSV files in ./Data directory
    dataframes = {
        "general_df": general_df,
        "general_arranged_df": arranged_general_df,
        "province_df": province_df,
        "province_arranged_df": arranged_province_df,
        "ruler_df": ruler_df,
    }
    save_dataframes_to_csv(dataframes, save_dir="./Data", sep=",")
