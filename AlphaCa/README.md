# [AlphaCa (AI Tic-Tac-Toe)]

Rage against the **AlphaGo**


- [AlphaCa 2 (2016.03.13)](/AlphaCa#alphaca-2-20160313)
- [AlphaCa 1 (2016.03.11)](/AlphaCa#alphaca-1-20160311)



## [AlphaCa 2 (2016.03.13)](/AlphaCa#alphaca-ai-tic-tac-toe)

- Judge the winner in several cases
- Not completed (should find more proper case to explain the code)


## [AlphaCa 1 (2016.03.11)](/AlphaCa#alphaca-ai-tic-tac-toe)

- Generate randomized cases and find if the winner exists


### 0. Cases

```r
factorial(361)                                              # Go-game : 19 * 19 = 361 points
exp(sum(log(1:361)))
sum(log(1:361, base=10))                                    # 768.1577
10^0.1577                                                   # → 1.437805 * 10^768
```
> [1] Inf  
> [1] Inf  
> [1] 768.1577  
> [1] 1.437805

```r
factorial(9)                                                # Tic-Tac-Toe : 362,880
factorial(9)/(2*2*2^4)                                      # eliminate symmetries of top and bottom(/2), left and right(/2), diagonals(/4) : 1/16 → 5,670
```
> [1] 362880  
> [1] 5670


### 1. Generate randomized cases as array

```r
a <- rank(runif(9), ties.method="random"); a
matrix(a, nrow=3, ncol=3)
```
> [1] 2 9 7 5 1 3 8 6 4

> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
> [1,] &nbsp;&nbsp; 2 &nbsp;&nbsp; 5 &nbsp;&nbsp; 8  
> [2,] &nbsp;&nbsp; 9 &nbsp;&nbsp; 1 &nbsp;&nbsp; 6  
> [3,] &nbsp;&nbsp; 7 &nbsp;&nbsp; 3 &nbsp;&nbsp; 4


### 1.1 5 cases

```r
set.seed(0307)                                              # the seed number works during the following for statement …… crazy!
k=5; aa <- c(); a.arr <- c()

for(i in 1:k) {
    a <- rank(runif(9), ties.method="random")
    aa <- c(aa, a)
    }

a.arr <- array(aa, c(3,3,k))
a.arr
```
> , , 1  
> 
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
> [1,] &nbsp;&nbsp; 6 &nbsp;&nbsp; 3 &nbsp;&nbsp; 2  
> [2,] &nbsp;&nbsp; 5 &nbsp;&nbsp; 1 &nbsp;&nbsp; 8  
> [3,] &nbsp;&nbsp; 4 &nbsp;&nbsp; 7 &nbsp;&nbsp; 9  
> ……


### 1.1.1 100K cases

```r
set.seed(0307)
k=10^5; aa <- c(); a.arr <- c()

for(i in 1:k) {
    a <- rank(runif(9), ties.method="random")
    aa <- c(aa, a)
    }

a.arrow <- array(aa, c(3,3,k))
str(a.arrow)
```
>  int [1:3, 1:3, 1:100000] 6 5 4 3 1 7 2 8 9 3 ...


### 1.2 Find if each case has the winner

&nbsp; (1) Fill number of 1~9 instead of O/X  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : The 1st Player puts (1, 3, 5, 7, 9) and the 2nd player does (2, 4, 6, 8).  
&nbsp; (2) It is the winner who puts only odd or only even numbers in a line including diagonal ones  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : If there are two or more such lines, the winner is who has the smaller max value.

```r
a.arrow[,,41562]                                            # winner : 1nd player (3-1-5 on the '\' line)
```
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
> [1,] &nbsp;&nbsp; 3 &nbsp;&nbsp; 9 &nbsp;&nbsp; 6  
> [2,] &nbsp;&nbsp; 2 &nbsp;&nbsp; 1 &nbsp;&nbsp; 7  
> [3,] &nbsp;&nbsp; 4 &nbsp;&nbsp; 8 &nbsp;&nbsp; 5

```r
a.arrow[,2,41562]
diag(a.arrow[,,41562])
n=41562; c(a.arrow[1,3,n],a.arrow[2,2,n],a.arrow[3,1,n])
```
> [1] 9 1 8  
> [1] 3 1 5  
> [1] 6 1 4

```r
a.arrow[,3,41562]%%2                                        # 0 : even number / 1 : odd number
diag(a.arrow[,,41562])%%2                                   # 1 1 1 : consists of only odd numbers
```
> [1] 0 1 1  
> [1] 1 1 1