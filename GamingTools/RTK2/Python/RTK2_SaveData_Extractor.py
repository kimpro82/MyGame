"""
RTK2 ERP / Extract and Arrange the Ruler, Province, and General Data from the Save File.

Author : kimpro82
Date: 2025.07.06

This script extracts, links, and summarizes ruler, province, and general data from a RTK2 save file.
It builds DataFrames for each entity, traverses linked lists to reflect in-game order, and aggregates statistics for analysis or export.

Functions:
- read_binary_file(filename): Read file in binary mode and return bytes
- extract_generals_from_save(data): Extract generals from binary data
- extract_provinces_with_generals(data, generals_df): Extract provinces, referencing generals for governor info
- extract_rulers_with_provinces_and_generals(data, generals_df): Extract rulers, referencing generals for names
- link_provinces_by_ruler(rulers_df, provinces_df): Traverse province linked lists for each ruler
- link_generals_by_province(provinces_df, generals_df): Traverse general linked lists for each province
- summarize_province_with_generals(provinces_df, generals_df): Aggregate province-level stats (soldiers, general counts, etc)
- summarize_ruler_with_provinces_and_generals(rulers_df, provinces_df, generals_df): Aggregate ruler-level stats
- save_dataframes_to_csv(dataframes, save_dir, sep): Save DataFrames to CSV
"""


import os
import pandas as pd


def read_binary_file(filename):
    """Read the specified file in binary mode and return the byte data."""

    with open(filename, "rb") as f:
        data_bytes = f.read()

    return data_bytes


def extract_generals_from_save(data_bytes, start=32, length=43, count=255):
    """
    Extract general (officer) data from the binary file.
    Returns a DataFrame with one row per general.
    """

    generals_list = []
    for i in range(count):
        offset = start + i * length
        chunk = data_bytes[offset:offset+length]
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
        generals_list.append(general)

    return pd.DataFrame(generals_list)

def extract_provinces_with_generals(data_bytes, df_generals, start=11660, length=35, count=41):
    """
    Extract province data from the binary file.
    Returns a DataFrame with one row per province.
    Each province contains a linked list pointer (next_prov_idx) and a governor index.
    """

    provinces_list = []
    for i in range(count):
        offset = start + i * length
        chunk = data_bytes[offset:offset+length]
        ruler_idx = chunk[16]
        governor_idx = int(max((chunk[2] + chunk[3] * 256 - 88) / 43, -1))
        province = {
            "prov_idx": i + 1,  # 1-based province index
            "next_prov_idx": int(max((chunk[0] + chunk[1] * 256 - 21 -11660)/35, -1)),  # Next province in ruler's list
            "governor_idx": governor_idx,  # Index of the governor general
            "governor": df_generals.iloc[governor_idx]["name"] if ruler_idx >= 0 else "",
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
        provinces_list.append(province)

    return pd.DataFrame(provinces_list)


def extract_rulers_with_provinces_and_generals(data_bytes, df_generals, start=11004, length=41, count=16):
    """
    Extract ruler data from the binary file.
    Returns a DataFrame with one row per ruler.
    Each ruler contains a capital province index and summary stats.
    """

    rulers_list = []
    for i in range(count):
        offset = start + i * length
        chunk = data_bytes[offset:offset+length]
        ruler_idx = int(max((chunk[0] + chunk[1] * 256 -88)/43, -1))
        advisor_idx = int(max((chunk[4] + chunk[5] * 256 - 88)/43, -1))
        capital_idx = int((chunk[2] + chunk[3] * 256 - 21 -11660)/35)  # Capital province index
        ruler = {
            "ruler_idx": ruler_idx,
            "ruler_name": df_generals.iloc[ruler_idx]["name"] if ruler_idx >= 0 else "",
            "capital_idx": capital_idx if ruler_idx >= 0 else "",
            "advisor_idx": advisor_idx,
            "advisor_name": df_generals.iloc[advisor_idx]["name"] if advisor_idx >= 0 else "",
            "trust": chunk[6],
        }
        rulers_list.append(ruler)

    return pd.DataFrame(rulers_list)


def link_provinces_by_ruler(df_rulers, df_provinces):
    """
    For each ruler, traverse the province linked list starting from capital_idx.
    Collect all province rows in order for each ruler. After all rulers, add remaining unowned provinces (ruler_idx == 255).
    Returns a DataFrame with the arranged province order.
    """

    linked_rows = []
    visited_prov = set()
    for _, ruler_row in df_rulers.iterrows():
        current_idx = ruler_row["capital_idx"]
        while current_idx != -1 and current_idx not in visited_prov:
            visited_prov.add(current_idx)
            prov_row = df_provinces[df_provinces["prov_idx"] == current_idx]
            if not prov_row.empty:
                row_dict = prov_row.iloc[0].to_dict()
                row_dict["ruler_name"] = ruler_row["ruler_name"]
                linked_rows.append(row_dict)
                current_idx = row_dict["next_prov_idx"]
            else:
                break

    # Add unowned provinces (ruler_idx == 255) that were not visited
    unowned = df_provinces[(df_provinces["ruler_idx"] == 255) & (~df_provinces["prov_idx"].isin(visited_prov))]
    for _, prov_row in unowned.iterrows():
        row_dict = prov_row.to_dict()
        row_dict["ruler_idx"] = 255
        row_dict["ruler_name"] = "Empty"
        linked_rows.append(row_dict)

    return pd.DataFrame(linked_rows)


def link_generals_by_province(df_provinces, df_generals):
    """
    For each province in df_provinces, traverse the general linked list starting from governor_idx.
    Collect all general rows in order for each province.
    Returns a DataFrame with the arranged general order.
    """

    linked_rows = []
    for _, prov_row in df_provinces.iterrows():
        current_gen_idx = prov_row["governor_idx"]
        visited_gen = set()
        while current_gen_idx != -1 and current_gen_idx not in visited_gen:
            visited_gen.add(current_gen_idx)
            gen_row = df_generals[df_generals["general_idx"] == current_gen_idx]
            if not gen_row.empty:
                row_dict = gen_row.iloc[0].to_dict()
                row_dict["prov_idx"] = prov_row["prov_idx"]
                row_dict["prov_governor"] = prov_row["governor"]
                row_dict["prov_ruler"] = prov_row["ruler_name"]
                linked_rows.append(row_dict)
                current_gen_idx = row_dict["next_gen_idx"]
            else:
                break

    return pd.DataFrame(linked_rows)


def summarize_province_with_generals(df_provinces, df_generals):
    """
    For each province, calculate:
      - soldiers_sum: sum of soldiers of all generals in the province
      - gen_cnt: count of generals whose ruler_idx matches the province's ruler_idx
      - free_cnt: count of generals whose ruler_idx == 255 (free officers)
    Returns a DataFrame with these columns added.
    """

    summary_rows = []
    for _, prov_row in df_provinces.iterrows():
        prov_idx = prov_row["prov_idx"]
        prov_ruler_idx = prov_row["ruler_idx"]
        mask_prov = df_generals['prov_idx'] == prov_idx
        generals_in_prov = df_generals[mask_prov]

        row_summary = prov_row.copy()
        row_summary['soldiers_sum'] = generals_in_prov['soldiers'].sum()
        row_summary['gen_cnt'] = (generals_in_prov['ruler_idx'] == prov_ruler_idx).sum()
        row_summary['free_cnt'] = (generals_in_prov['ruler_idx'] == 255).sum()
        summary_rows.append(row_summary)

    return pd.DataFrame(summary_rows)


def summarize_ruler_with_provinces_and_generals(df_rulers, df_provinces, df_generals):
    """
    For each ruler, aggregate province and general statistics from df_provinces and df_generals.
    Adds the following columns to ruler_df:
      - prov_cnt: number of provinces owned
      - gold_sum, food_sum, pop_sum: sum of each for owned provinces
      - soldiers_sum: sum of soldiers for generals belonging to the ruler
      - gen_cnt: sum of gen_cnt from owned provinces (generals belonging to the ruler)
      - free_cnt: sum of free_cnt from owned provinces (free officers in ruler's provinces)
    Returns the updated DataFrame.
    """

    summary_rows = []
    for _, ruler_row in df_rulers.iterrows():
        ruler_idx = ruler_row['ruler_idx']
        ruler_name = ruler_row.get('ruler_name', '')
        mask_prov = df_provinces['ruler_idx'] == ruler_idx
        mask_gen = df_generals['prov_ruler'] == ruler_name

        row_summary = ruler_row.copy()
        row_summary['prov_cnt'] = mask_prov.sum()
        row_summary['gold_sum'] = df_provinces.loc[mask_prov, 'gold'].sum()
        row_summary['food_sum'] = df_provinces.loc[mask_prov, 'food'].sum()
        row_summary['pop_sum'] = df_provinces.loc[mask_prov, 'pop'].sum()
        row_summary['soldiers_sum'] = df_generals.loc[mask_gen, 'soldiers'].sum()
        row_summary['gen_cnt'] = df_provinces.loc[mask_prov, 'gen_cnt'].sum()
        row_summary['free_cnt'] = df_provinces.loc[mask_prov, 'free_cnt'].sum()
        summary_rows.append(row_summary)

    return pd.DataFrame(summary_rows)


def save_dataframes_to_csv(dataframes, save_dir="./Data", sep=","):
    """
    Save multiple DataFrames to CSV files in the specified directory. Create the directory if it does not exist.
    Args:
        dataframes (dict): {filename(str): dataframe(pd.DataFrame)}
        save_dir (str): Directory to save CSV files.
        sep (str): Delimiter to use (default: ','). Use '\t' for tab-separated.
    """

    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    for name, df in dataframes.items():
        path = os.path.join(save_dir, f"{name}.csv")
        df.to_csv(path, index=False, sep=sep)

    print(f"DataFrames have been saved to {save_dir} as CSV files (sep='{sep}').")

    return


if __name__ == "__main__":
    # Target filename constant
    FILENAME = "SC5TEST"

    # Extract general, province, and ruler data
    binary_data = read_binary_file(FILENAME)
    general_df = extract_generals_from_save(binary_data)
    province_df = extract_provinces_with_generals(binary_data, general_df)
    ruler_df = extract_rulers_with_provinces_and_generals(binary_data, general_df)

    # Arrange province and general data by linked list order
    linked_province_df = link_provinces_by_ruler(ruler_df, province_df)
    linked_general_df = link_generals_by_province(linked_province_df, general_df)
    summarized_province_df = summarize_province_with_generals(linked_province_df, linked_general_df)
    summarized_ruler_df = summarize_ruler_with_provinces_and_generals(ruler_df, summarized_province_df, linked_general_df)

    # Print sample outputs
    print("General DataFrame (first 5 rows):")
    print(linked_general_df.head(), "\n")
    print("Province DataFrame 2 (first 5 rows):")
    print(summarized_province_df.head(), "\n")
    print("Ruler DataFrame (first 5 rows):")
    print(summarized_ruler_df.head(), "\n")

    # Save DataFrames to CSV files in ./Data directory
    dfs = {
        # "general_df": general_df,
        "general_df": linked_general_df,
        # "province_df": province_df,
        "province_df": summarized_province_df,
        "ruler_df": summarized_ruler_df,
    }
    save_dataframes_to_csv(dfs, save_dir="./Data", sep=",")
