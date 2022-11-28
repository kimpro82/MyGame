# RTK2 Analysis


# Topics

# 0. Load data
# 0.1 Practice : Load raw data from a scenario
# 0.2 Find all the locations of the general data
# 0.3 Load entire raw data from all scenarios
# 1. Basic Data Analysis
# 1.x abilities' distribution and so on ……
# 2. Advanced Data Analysis
# 2.1 K-means clustering
# 2.2 PCA
# 3. Interesting Questions
# 3.1 Predict Where a general belongs to
# 3.2 Who will be the betrayers?


if (!requireNamespace("ggplot2")) install.packages("ggplot2")
library(ggplot2)


# 0. Load data


# 0.1 Practice : Load raw data from a scenario
# 2022.06.24

# 1) Read binary data
setwd("{Working Directory}")

path = "SCENARIO.DAT"
read.filename <- file(path, "rb")
bindata <- readBin(read.filename, raw(), n = 79385)
head(bindata)                                               # ok

# 2) Read a general's data in S5
# S5 data = 52946 ~ 61373 (43 term per 1 general)
start = 52946 + 1
end = 61373 + 1
interval = 43
bindata[start:(start + interval - 1)]                       # Cao Cao
as.integer(bindata[start:(start + interval - 1)])           # hex → dec

# 3) Read all generals' data in S5
s5bin <- matrix(bindata[start:end], ncol = 43, byrow = TRUE)
head(s5bin)                                                 # ok

# 4) Read all generals' names in S5
s5name <- c()
s5len = as.integer(end - start + 1) / interval              # 196
for (i in 1:s5len) {
    s5name <- c(s5name, rawToChar(s5bin[i,29:43]))
}
s5name                                                      # Ok : Cao Cao ~ Chen Tai (196)


# 0.2 Find all the locations of the general data
# 2022.11.25

# Declare a dataframe that contains the general data's locations

# 1) Find all the scenario' general data locations
# s1 : 22 ~ 6471 (start from 0)
# s2 : 13253 ~ 21981
# s3 : 26484 ~ 35513
# s4 : 39715 ~ 48916
# s5 : 52946 ~ 61373
# s6 : 66177 ~ 74088

# 2) Declare a dataframe for all scenarios' general data location
s_start = c(22, 13253, 26484, 39715, 52946, 66177)
s_end   = c(6471, 21981, 35513, 48916, 61373, 74088)
t_start = c(6, 7458, 12288, 15784, 17762, 18774)
t_end   = c(7457, 12287, 15783, 17761, 18773, 19325)
s_num   = c(s_end - s_start + 1) / 43
t_num   = c(t_end - t_start + 1) / 46

sDataLocation <- data.frame(
    scenario = rep(1:6, each = 2),
    category = rep(c("scenario", "taiki"), 6),
    start    = c(matrix(rbind(s_start, t_start), nrow = 1)),
    end      = c(matrix(rbind(s_end, t_end), nrow = 1)),
    num      = c(matrix(rbind(s_num, t_num), nrow = 1))
)
sDataLocation
sDataLocation[sDataLocation$category=="scenario",]

# 3) Draw a stacked barplot with label
ggplot(sDataLocation, aes(x = scenario, y = num, fill = category, label = num)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = num), size = 3, hjust = 0.5, vjust = 3, position ="stack") 
# The ggplot2 library doesn't work on my local desktop.
# Alternative : Run on https://rdrr.io/snippets/

# Hmm …… it seems to need to find how to join the whole data from SCENARIO.DAT and TAIKI.DAT