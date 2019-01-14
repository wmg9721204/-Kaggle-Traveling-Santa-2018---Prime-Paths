using LinearAlgebra
"""
CutHalf2 is a function bisecting a given point cloud into two sub-point clouds. <br>

Usage: CutHalf2(X::Array{Float64,2}, a::Int, b::Int)

**Inputs**:
1. X, the point cloud, stored as a matrix, where each column is a point.
2. a, the first center, stored as an integer, referring to the ath column of X
3. b, the second center, stored as an integer, referring to the bth column of X

**Output**:
a pair (C_a, C_b), where C_a records the indices of the first sub-point cloud and C_b the second. 
"""
function CutHalf2(X::Array{Float64,2}, a::Int, b::Int)
    if !((1<=a<=size(X,2))&&(1<=b<=size(X,2)))
        error("One (or all) of the points assigned are out of range!!!")
    elseif a==b
        error("The two assigned points must be different!!!")
    end
    C_a = findall([norm(X[:,i]-X[:,a]) for i=1:size(X,2)].<[norm(X[:,i]-X[:,b]) for i=1:size(X,2)])
    C_b = setdiff(collect(1:size(X,2)), C_a)
    return (C_a, C_b)
end