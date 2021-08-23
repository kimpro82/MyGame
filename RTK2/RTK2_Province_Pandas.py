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