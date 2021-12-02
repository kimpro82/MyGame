# [AlphaCa (AI Tic-Tac-Toe)]

Rage against the **AlphaGo**

- [AlphaCa 2 (2016.03.13)](/AlphaCa#alphaca-2-20160313)
- [AlphaCa 1 (2016.03.11)](/AlphaCa#alphaca-1-20160311)


## [AlphaCa 2 (2016.03.13)](/AlphaCa#alphaca-ai-tic-tac-toe)

- Judge the winner

### 2-1. Case that has two lines of odd sum
```r
k=86532; a.arrow[,,k]                                                   # Winner : 1st (5-3-7 for the '/' line, not 9-3-1 on the 2nd column)
```

### 2-1-1. Get sums of all the lines
```r
wl <- c()                                                               # wl(win/lose) : 0 (2nd player wins) / 1~2 (draw) / 3 (1st one wins)
for (i in 1:3) {
	wl <- c(wl, sum(a.arrow[,i,k]%%2))
	}
for (i in 1:3) {
	wl <- c(wl, sum(a.arrow[i,,k]%%2))
	}
wl <- c(wl, sum(diag(a.arrow[,,k])%%2))
wl <- c(wl, sum(c(a.arrow[1,3,k],a.arrow[2,2,k],a.arrow[3,1,k])%%2))
wl; mm <- c(max(wl), min(wl)); mm
```

### 2-1-2. Improved code : add wl.max
```r
wl <- c(); wl.max <- c()                                       			# wl.max : the max number of each line
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

wl.max.rank <- which(wl==max(wl)); wl.max.rank
wl.max.real <- min(wl.max[wl.max.rank]); wl.max.real
wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank

wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq
wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq)))); wl.rmr
winner <- wl[wl.rmr]; winner
```

### 2-2. Case that hase lines of even sum and odd one at the same time
```r
k=86537; a.arrow[,,k]

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

wl.win.rank <- which(wl==c(3,0)); wl.win.rank
wl.max.real <- min(wl.max[wl.win.rank]); wl.max.real

wl.max.real.rank <- which(wl.max==wl.max.real); wl.max.real.rank
wl.mrr.freq <- table(c(wl.max.rank, wl.max.real.rank)); wl.mrr.freq
wl.rmr <- as.numeric(names(which(wl.mrr.freq==max(wl.mrr.freq)))); wl.rmr
winner <- wl[wl.rmr]; winner
```


## [AlphaCa 1 (2016.03.11)](/AlphaCa#alphaca-ai-tic-tac-toe)

- Generate randomized cases

### 0. Cases
```r
factorial(361)                                  			# Go-game : 19 * 19 = 361 points
exp(sum(log(1:361)))
sum(log(1:361, base=10)); 10^0.1577             			# 1.437805 * 10^768

factorial(9)                                    			# Tic-Tac-Toe : 362,880
factorial(9)/(2*2*2^4)                          			# eliminate symmetries of top and bottom(/2), left and right(/2), diagonals(/4) : 1/16 → 5,670
```

### 1. Generate randomized cases as array
```r
a <- rank(runif(9), ties.method="random"); a
matrix(a, nrow=3, ncol=3)
```

### 1.1 5 cases
```r
set.seed(0307); k=5; aa <- c(); a.arr <- c()
for(i in 1:k) {
	a <- rank(runif(9), ties.method="random")
	aa <- c(aa, a)
	}
a.arr <- array(aa, c(3,3,k))
a.arr
```

### 1.2 Find if each case has the winner
```r
# (1) Fill number of 1~9 instead of O/X
#     : The 1st Player puts (1, 3, 5, 7, 9) and the 2nd player does (2, 4, 6, 8).
# (2) It is the winner who puts only odd or only even numbers in a line including diagonal ones
#     : If there are two or more such lines, the winner is who has the smaller max value.

a.arrow[,,41562]
a.arrow[,2,41562]
diag(a.arrow[,,41562])
n=41562; c(a.arrow[1,3,n],a.arrow[2,2,n],a.arrow[3,1,n])

a.arrow[,3,41562]%%2; diag(a.arrow[,,41562])%%2				# 0 : only even numbers / 3 : only odd numbers
```