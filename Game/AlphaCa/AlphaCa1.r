# Alphaca : AI(?) Tic-Tac-Toe / 2016.3.11


# 0. The number of cases

factorial(361)                                              # Go-game : 19 * 19 = 361 points
exp(sum(log(1:361)))
sum(log(1:361, base=10))                                    # 768.1577
10^0.1577                                                   # → 1.437805 * 10^768

factorial(9)                                                # Tic-Tac-Toe : 362,880
factorial(9)/(2*2*2^4)                                      # eliminate symmetries of top and bottom(/2), left and right(/2), diagonals(/4) : 1/16 → 5,670


# 1. Generate randomized cases as array

a <- rank(runif(9), ties.method="random"); a
matrix(a, nrow=3, ncol=3)


# 1.1 5 cases

set.seed(0307)                                              # the seed number works during the following for statement …… crazy!
k=5; aa <- c(); a.arr <- c()

for(i in 1:k) {
    a <- rank(runif(9), ties.method="random")
    aa <- c(aa, a)
    }

a.arr <- array(aa, c(3,3,k))
a.arr


# 1.1.1 100K cases

set.seed(0307)
k=10^5; aa <- c(); a.arr <- c()                             # I realized such numerous cases is not needed, when it was too late.

for(i in 1:k) {
    a <- rank(runif(9), ties.method="random")
    aa <- c(aa, a)
    }

a.arrow <- array(aa, c(3,3,k))
str(a.arrow)


# 1.2 Find if each case has the winner

# (1) Fill number of 1~9 instead of O/X
#     : The 1st Player puts (1, 3, 5, 7, 9) and the 2nd player does (2, 4, 6, 8).
# (2) It is the winner who puts only odd or only even numbers in a line including diagonal ones
#     : If there are two or more such lines, the winner is who has the smaller max value(to be continued ……).

a.arrow[,,41562]                                            # winner : 1nd player (3-1-5 on the '\' line)

a.arrow[,2,41562]
diag(a.arrow[,,41562])
n=41562; c(a.arrow[1,3,n],a.arrow[2,2,n],a.arrow[3,1,n])

a.arrow[,3,41562]%%2                                        # 0 : even number / 1 : odd number
diag(a.arrow[,,41562])%%2                                   # 1 1 1 : consists of only odd numbers