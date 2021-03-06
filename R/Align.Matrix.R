# Align.Matrix is an R function to reflect and interchange columns of Input.Matrix to match
# those of Order.Matrix. Becuase it considers all possible permutations of columns of Input.Matrix,
# the best match in terms of the smallest sum of squared deviations between these two matrices can always be found.
# It works well when the number of factors is not too large.
# Updated on 2016-06-16 to include an internal function fn_perm_list, Guangjian Zhang
# Updated on 2016-06-30 to accommodate partially specified order matrices, Guangjian Zhang


# 
# Order.Matrix, an input argument, p by m
# Input.Matrix, an input argument, (p+m) by m, the first p rows are factor loadings, the last m rows are factor correlations
# Output.Matrix, an output argument, (p+m+1) by m, the last row contains the sums of squared deviations for the best match
# and the second best match. The difference between the best match and the second best match could be considered as a confidence
# on the success of the aligning procedure.


Align.Matrix <- function(Order.Matrix, Input.Matrix, Weight.Matrix=NULL) {

#--------------------------------------------------------
fn_perm_list <- function (n, r, v = 1:n) {  # It is taken from the package gregmisc
    if (r == 1)
       matrix(v, n, 1)
    else if (n == 1)
       matrix(v, 1, r)
    else {
       X <- NULL
       for (i in 1:n) X <- rbind(X, cbind(v[i], fn_perm_list(n -
            1, r - 1, v[-i])))
        X
    }
 }

#--------------------------------------------------------


p = nrow(Order.Matrix)
m = ncol(Order.Matrix)

if (is.null(Weight.Matrix)) Weight.Matrix = matrix(1,p,m)

Permutation = fn_perm_list(m,m)
Factorial.m = nrow(Permutation)

Loading.Matrix = Input.Matrix[1:p,1:m]
Phi.Matrix = Input.Matrix[(p+1):(p+m),1:m]

# Step 1
# obtain sum of squared deviations of columns of Order.Matrix and Input.Matrix
# Rows correspond to Order.Matrix
# Columns Correspond to Input.Matrix

Squared.Deviation = diag(m)

Order.Matrix.abs = abs(Order.Matrix)
Loading.Matrix.abs = abs(Loading.Matrix)

for (i in 1:m) {
    temp1= sum(Order.Matrix.abs[1:p,i] * Order.Matrix.abs[1:p,i] * Weight.Matrix[1:p,i])
   for (j in 1:m) {
    temp2 = sum(Loading.Matrix.abs[1:p,j] * Loading.Matrix.abs[1:p,j] * Weight.Matrix[1:p,i])
    temp3 = sum(Order.Matrix.abs[1:p,i] * Loading.Matrix.abs[1:p,j]  * Weight.Matrix[1:p,i])
    Squared.Deviation[i,j] = temp1 + temp2 - 2 * abs(temp3)  
                 } # (j in 1:m)
              } # (i in 1:m)


# Step 2, find the best match betwen the Order.Matrix and Loading.Matrix

Squared.Deviation.Permutation = rep(0,Factorial.m)
for (i in 1:Factorial.m) {
for (j in 1:m) {
 Squared.Deviation.Permutation[i] = Squared.Deviation.Permutation[i] + Squared.Deviation[j,Permutation[i,j]]
}
}


Match = order(Squared.Deviation.Permutation)


# step 3, Interchange columns of the factor loading matrix to match the target factor loading matrix

Temp.Loading.Matrix = Loading.Matrix
Temp.Phi.Matrix = Phi.Matrix

for (i in 1:m) {
Temp.Loading.Matrix[1:p,i] = Loading.Matrix[1:p,Permutation[Match[1],i]]
}

 for (i in 1:m) {
  for (j in 1:m) {
   Temp.Phi.Matrix[i,j] = Phi.Matrix[Permutation[Match[1],i],Permutation[Match[1],j]]   
 }
}


## Step 4, reflect columns of Phi.Matrix if needed

for (j in 1:m) {

temp1 = sum (Order.Matrix[1:p,j] * Temp.Loading.Matrix[1:p,j])

 if (temp1 < 0) {
 Temp.Loading.Matrix[1:p,j] = Temp.Loading.Matrix[1:p,j] * (-1)
 Temp.Phi.Matrix[j,1:m] = Temp.Phi.Matrix[j,1:m] * (-1)
 Temp.Phi.Matrix[1:m,j] = Temp.Phi.Matrix[1:m,j] * (-1) 
                } # if (temp1 < 0)

} # for (j in 1:m)


Output.Matrix = array (rep(0,(p+m+1)*m), dim=c((p+m+1),m))
Output.Matrix[1:p,1:m] = Temp.Loading.Matrix[1:p,1:m]
Output.Matrix[(p+1):(p+m),1:m] = Temp.Phi.Matrix[1:m,1:m]
Output.Matrix[(p+m+1),1] = Squared.Deviation.Permutation[Match[1]]
Output.Matrix[(p+m+1),2] = Squared.Deviation.Permutation[Match[2]]

Output.Matrix

} # Align.Matrix <- function(Order.Matrix, Input.Matrix)

#################################################################################################################