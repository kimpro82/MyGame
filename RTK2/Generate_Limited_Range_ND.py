# Generating a normal distribution with limited range [25, 75]

import numpy as np
import matplotlib.pyplot as plt

from scipy import stats

mu, sigma, n = 50, 10, 1000
llimit, rlimit = 25, 75

data = np.random.normal(mu, sigma, n)


# Method 0. Generating initial data (not trimmed yet)

plt.hist(data)
stats.describe(data)[0:2] # [0] : nobs, [1] : minmax


# Method 1. Trim with rack of amount

data1 = data[(data >= llimit) & (data <= rlimit)]

plt.hist(data1)
stats.describe(data1)[0:2]


# Method 2. Check each one trial

data2, amount = [], 0

while amount < n :
    data_temp = np.random.normal(mu, sigma, 1)
    if (data_temp >= llimit) & (data_temp <= rlimit) :
        data2 = np.append(data2, data_temp)
        amount += 1

plt.hist(data2)
stats.describe(data2)[0:2]


# Method 3. Generate one round and fill the lack

data3 = data[(data >= llimit) & (data <= rlimit)]
amount = len(data3)

while amount < n :
    data_temp = np.random.normal(mu, sigma, 1)
    if (data_temp >= llimit) & (data_temp <= rlimit) :
        data3 = np.append(data3, data_temp)
        amount += 1

plt.hist(data3)
stats.describe(data3)[0:2]
