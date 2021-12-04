# Alphaca : AI(?) Tic-Tac-Toe / 2016.3.13


# 2. Judge the winner


# 2.1. An improved way to find if the winner exists

k=86532; a.arrow[,,k]                                                   # winner : 2nd player (8-4-6 on the '\' line)


# 2.1.1. Get the max and min value from wl

wl <- c()                                                               # wl(win/lose) : 0 (2nd player wins) / 1~2 (draw) / 3 (1st one wins)

for (i in 1:3) {
    wl <- c(wl, sum(a.arrow[,i,k]%%2))
    }

for (i in 1:3) {
    wl <- c(wl, sum(a.arrow[i,,k]%%2))
    }

wl <- c(wl, sum(diag(a.arrow[,,k])%%2))
wl <- c(wl, sum(c(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])%%2)); wl
mm <- c(max(wl), min(wl)); mm                                           # mm : max and min value from wl


# 2-1-2. Improved code : add wl.max

wl <- c()
wl.max <- c()                                                           # wl.max : the max number of each line

for (i in 1:3) {
    wl <- c(wl, sum(a.arrow[,i,k]%%2))
    wl.max <- c(wl.max, max(a.arrow[,i,k]))
    }

for (i in 1:3) {
    wl <- c(wl, sum(a.arrow[i,,k]%%2))
    wl.max <- c(wl.max, max(a.arrow[i,,k]))
    }

wl <- c(wl, sum(diag(a.arrow[,,k])%%2))
wl.max <- c(wl.max, max(diag(a.arrow[,,k])))
wl <- c(wl, sum(c(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])%%2))
wl.max <- c(wl.max, max(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])); wl
mm <- c(max(wl), min(wl)); mm
wl.max

wl.max.rank <- which(wl==max(wl)); wl.max.rank
wl.max.real <- min(wl.max[wl.max.rank]); wl.max.real
wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank

wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq
wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq)))); wl.rmr
winner <- wl[wl.rmr]; winner


# 2-2. Case that has lines of even sum and odd one at the same time

k=86537; a.arrow[,,k]

wl <- c()
wl.max <- c()

for (i in 1:3) {
    wl <- c(wl, sum(a.arrow[,i,k]%%2))
    wl.max <- c(wl.max, max(a.arrow[,i,k]))
    }

for (i in 1:3) {
    wl <- c(wl, sum(a.arrow[i,,k]%%2))
    wl.max <- c(wl.max, max(a.arrow[i,,k]))
    }

wl <- c(wl, sum(diag(a.arrow[,,k])%%2))
wl.max <- c(wl.max, max(diag(a.arrow[,,k])))
wl <- c(wl, sum(c(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])%%2))
wl.max <- c(wl.max, max(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])); wl
mm <- c(max(wl), min(wl)); mm
wl.max

wl.win.rank <- which(wl==c(3,0)); wl.win.rank
wl.max.real <- min(wl.max[wl.win.rank]); wl.max.real

wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank
wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq
wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq)))); wl.rmr
winner <- wl[wl.rmr]; winner