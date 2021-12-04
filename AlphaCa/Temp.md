### 2-1. An improved way to find if the winner exists

```r
k=86532; a.arrow[,,k]                                                   # winner : 2nd player (8-4-6 on the '\' line)
```
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
> [1,] &nbsp;&nbsp; 8 &nbsp;&nbsp; 5 &nbsp;&nbsp; 1  
> [2,] &nbsp;&nbsp; 7 &nbsp;&nbsp; 4 &nbsp;&nbsp; 2  
> [3,] &nbsp;&nbsp; 9 &nbsp;&nbsp; 3 &nbsp;&nbsp; 6


### 2.1.1. Get the max and min value from `wl`

```r
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
```
> [1] 2 2 1 2 1 2 0 2  
> [1] 2 0


### 2-1-2. Improved code : add wl.max

```r
wl <- c(); wl.max <- c()                                                # wl.max : the max number of each line
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
wl; mm <- c(max(wl), min(wl)); mm
wl.max
```
> [1] 2 2 1 2 1 2 0 2  
> [1] 2 0  
> [1] 9 5 6 8 7 9 8 9

```r
wl.max.rank <- which(wl==max(wl)); wl.max.rank
wl.max.real <- min(wl.max[wl.max.rank]); wl.max.real
wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank
```
> [1] 1 2 4 6 8  
> [1] 5  
> [1] 2

```r
wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq
wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq)))); wl.rmr
winner <- wl[wl.rmr]; winner
```
> 1 2 4 6 8  
> 1 2 1 1 1 

> [1] 2  
> [1] 2

### 2-2. Case that hase lines of even sum and odd one at the same time
```r
k=86537; a.arrow[,,k]
```
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
> [1,] &nbsp;&nbsp; 5 &nbsp;&nbsp; 3 &nbsp;&nbsp; 7  
> [2,] &nbsp;&nbsp; 8 &nbsp;&nbsp; 9 &nbsp;&nbsp; 2  
> [3,] &nbsp;&nbsp; 4 &nbsp;&nbsp; 1 &nbsp;&nbsp; 6

```r
wl <- c(); wl.max <- c()
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
wl; mm <- c(max(wl), min(wl)); mm
wl.max
```
> [1] 1 3 1 3 1 1 2 2  
> [1] 3 1

> [1] 8 9 7 7 9 6 9 9

```r
wl.win.rank <- which(wl==c(3,0)); wl.win.rank
wl.max.real <- min(wl.max[wl.win.rank]); wl.max.real
```
> integer(0)  
> [1] Inf

```r
wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank
wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq
wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq)))); wl.rmr
winner <- wl[wl.rmr]; winner
```
> integer(0)

> 1 2 4 6 8  
> 1 1 1 1 1 

> [1] 1 2 4 6 8  
> [1] 1 3 3 1 2