# Alphaca : AI(?) Tic-Tac-Toe / 2016.3.13


# 2. Judge the winner in more advanced way

k=86532; a.arrow[,,k]                                                   # winner : 2nd player (8-4-6 on the '\' line)

# Get the sums of remainders that are 0(all even) or 3(all odd)
wl <- c()                                                               # wl(win/lose) : 0 (2nd player wins) / 1~2 (draw) / 3 (1st one wins)
for (i in 1:3) {                                                        # combine colums
  wl <- c(wl, sum(a.arrow[,i,k]%%2))
}
for (i in 1:3) {                                                        # combine rows
  wl <- c(wl, sum(a.arrow[i,,k]%%2))
}
wl <- c(wl, sum(diag(a.arrow[,,k])%%2))                                 # combine \ diagonal 
wl <- c(wl, sum(c(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])%%2))    # combine / diagonal
wl                                                                      # 7th element is 0 → 2nd player won

# mm : max and min value from wl; check easier if a winner exists
mm <- c(max(wl), min(wl))
mm


# 2.1. Find the winner when there are two or more winning lines

k=86537; a.arrow[,,k]

# get wl.max with wl
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
wl.max <- c(wl.max, max(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k]))
wl                                                                      # 2, 4-th lines consist only of odd numbers
wl.max

# mm : max and min value from wl; check easier if a winner exists
mm <- c(max(wl), min(wl))
mm

# Find the final singular winner
wl.win.rank <- c(which(wl==3), which(wl==0)); wl.win.rank               # return 2, 4 where the winning lines are
wl.max.real <- min(wl.max[wl.win.rank]); wl.max.real                    # the min of the max values in 2, 4th lines is 7
wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank        # 7 is the max value of 3, 4th lines

wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq     # {4} is the intersection of {2, 4} and {3, 4}

wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq))));wl.rmr# return 4
winner <- wl[wl.rmr]
winner                                                                  # the 4th line indicates '3' → 1st player won!