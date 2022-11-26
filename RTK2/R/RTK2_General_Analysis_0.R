# RTK2 Analysis


# Topics

# 0. Load data
# 0.1 Practice : Load raw data from a scenario
# 1. Classification
# 1.1 Predict Where a general belongs to
# 1.2 Who are the betrayers?
# 2. Method
# 2.1 K-means clustering
# 2.2 PCA
# 2.3 Deep Learning


# 0. Load data

# 0.1 Practice : Load raw data from a scenario
# 2022.06.24

# Read binary data
setwd("{Working Directory}")

path = "SCENARIO.DAT"
read.filename <- file(path, "rb")
bindata <- readBin(read.filename, raw(), n = 79385)
head(bindata)                                               # ok

# Read a general's data in S5
# S5 data = 52946 ~ 61373 (43 term per 1 general)
start = 52946 + 1
end = 61373 + 1
interval = 43
bindata[start:(start + interval - 1)]                       # Cao Cao
as.integer(bindata[start:(start + interval - 1)])           # hex → dec

# Read all generals' data in S5
s5bin <- matrix(bindata[start:end], ncol = 43, byrow = TRUE)
head(s5bin)                                                 # ok

# Read all generals' names in S5
s5name <- c()
s5len = as.integer(end - start + 1) / interval              # 196
for (i in 1:s5len) {
    s5name <- c(s5name, rawToChar(s5bin[i,29:43]))
}
s5name                                                      # Ok : Cao Cao ~ Chen Tai (196)