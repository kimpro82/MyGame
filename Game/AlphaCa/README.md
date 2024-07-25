# [Game > AlphaCa (AI Tic-Tac-Toe)](/README.md#alphaca-ai-tic-tac-toe)

Rage against the **AlphaGo**


### \<List>

- [AlphaCa 2. Find the winner (2016.03.13)](#alphaca-2-find-the-winner-20160313)
- [AlphaCa 1. Generate randomized cases as array (2016.03.11)](#alphaca-1-generate-randomized-cases-as-array-20160311)


## [AlphaCa 2. Find the winner (2016.03.13)](#list)

- Find the winner in more advanced way
- Code and Result
  <details>
    <summary>2. Find the winner</summary>

    ```r
    k=86532; a.arrow[,,k]                                                   # winner : 2nd player (8-4-6 on the '\' line)
    ```
    > &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
    > [1,] &nbsp;&nbsp; 8 &nbsp;&nbsp; 5 &nbsp;&nbsp; 1  
    > [2,] &nbsp;&nbsp; 7 &nbsp;&nbsp; 4 &nbsp;&nbsp; 2  
    > [3,] &nbsp;&nbsp; 9 &nbsp;&nbsp; 3 &nbsp;&nbsp; 6

    ```r
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
    ```
    > [1] 2 2 1 2 1 2 0 2  
    > [1] 2 0
  </details>
  <details>
    <summary>2.1. Find the winner when there are two or more winning lines</summary>

    ```r
    k=86537; a.arrow[,,k]
    ```
    > &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
    > [1,] &nbsp;&nbsp; 5 &nbsp;&nbsp; 3 &nbsp;&nbsp; 7  
    > [2,] &nbsp;&nbsp; 8 &nbsp;&nbsp; 9 &nbsp;&nbsp; 2  
    > [3,] &nbsp;&nbsp; 4 &nbsp;&nbsp; 1 &nbsp;&nbsp; 6

    ```r
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
    ```
    > [1] 1 3 1 3 1 1 2 2  
    > [1] 8 9 7 7 9 6 9 9  
    > [1] 3 1

    ```r
    # Find the final singular winner
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
  </details>


## [AlphaCa 1. Generate randomized cases as array (2016.03.11)](#list)

- Generate randomized cases and find if the winner exists
- Code and Result
  <details>
    <summary>0. The number of cases</summary>

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
  </details>
  <details>
    <summary>1. Generate randomized cases as array</summary>

    ```r
    a <- rank(runif(9), ties.method="random"); a
    matrix(a, nrow=3, ncol=3)
    ```
    > [1] 2 9 7 5 1 3 8 6 4

    > &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [,1] [,2] [,3]  
    > [1,] &nbsp;&nbsp; 2 &nbsp;&nbsp; 5 &nbsp;&nbsp; 8  
    > [2,] &nbsp;&nbsp; 9 &nbsp;&nbsp; 1 &nbsp;&nbsp; 6  
    > [3,] &nbsp;&nbsp; 7 &nbsp;&nbsp; 3 &nbsp;&nbsp; 4
  </details>
  <details>
    <summary>1.1 5 cases</summary>

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
  </details>
  <details>
    <summary>1.1.1 100K cases</summary>

    ```r
    set.seed(0307)
    k=10^5; aa <- c(); a.arr <- c()                             # I realized such numerous cases is not needed, when it was too late.

    for(i in 1:k) {
        a <- rank(runif(9), ties.method="random")
        aa <- c(aa, a)
        }

    a.arrow <- array(aa, c(3,3,k))
    str(a.arrow)
    ```
    >  int [1:3, 1:3, 1:100000] 6 5 4 3 1 7 2 8 9 3 ...
  </details>
  <details>
    <summary>1.2 Find if each case has the winner</summary>

    1. Fill number of 1~9 instead of O/X  
    : The 1st Player puts (1, 3, 5, 7, 9) and the 2nd player does (2, 4, 6, 8).  
    2. It is the winner who puts only odd or only even numbers in a line including diagonal ones  
    : If there are two or more such lines, the winner is who has the smaller max value(to be continued ……).

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
  </details>
