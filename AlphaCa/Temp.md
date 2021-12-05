### 2.1. An improved way to find the winner

```r
k=86532; a.arrow[,,k]                                                   # winner : 2nd player (8-4-6 on the '\' line)
```
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
> [1,] &nbsp;&nbsp; 8 &nbsp;&nbsp; 5 &nbsp;&nbsp; 1  
> [2,] &nbsp;&nbsp; 7 &nbsp;&nbsp; 4 &nbsp;&nbsp; 2  
> [3,] &nbsp;&nbsp; 9 &nbsp;&nbsp; 3 &nbsp;&nbsp; 6


### 2.1.1. Get the sum of remainders from dividing by 2

```r
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

mm <- c(max(wl), min(wl))                                               # mm : max and min value from wl; check easier if a winner exists
mm
```
> [1] 2 2 1 2 1 2 0 2  
> [1] 2 0


### 2-1-2. Find the winner when there are two or more winning lines

```r
k=86537; a.arrow[,,k]
```
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
> [1,] &nbsp;&nbsp; 5 &nbsp;&nbsp; 3 &nbsp;&nbsp; 7  
> [2,] &nbsp;&nbsp; 8 &nbsp;&nbsp; 9 &nbsp;&nbsp; 2  
> [3,] &nbsp;&nbsp; 4 &nbsp;&nbsp; 1 &nbsp;&nbsp; 6

```r
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
wl <- c(wl, sum(c(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])%%2))
wl                                                                      # 2, 4-th lines consist only of odd numbers

mm <- c(max(wl), min(wl))
mm

wl.max <- c(wl.max, max(diag(a.arrow[,,k])))
wl.max <- c(wl.max, max(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k]))
wl.max                                                                  # wl.max : the max number of each line
```
> [1] 1 3 1 3 1 1 2 2  
> [1] 3 1  
> [1] 8 9 7 7 9 6 9 9

```r
wl.win.rank <- c(which(wl==3), which(wl==0)); wl.win.rank               # return 2, 4 where the winning lines are
wl.max.real <- min(wl.max[wl.win.rank]); wl.max.real                    # the min of the max values in 2, 4th lines is 7
wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank        # 7 is the max value of 3, 4th lines

wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq     # {4} is the intersection of {2, 4} and {3, 4}

wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq))));wl.rmr# return 4
winner <- wl[wl.rmr]
winner                                                                  # the 4th line indicates '3' → 1st player won!
```
> [1] 2 4  
> [1] 7  
> [1] 3 4

> 2 3 4  
> 1 1 2

> [1] 4  
> [1] 3