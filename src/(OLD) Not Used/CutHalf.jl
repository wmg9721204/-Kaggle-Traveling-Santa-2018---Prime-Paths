using LinearAlgebra #"norm"
"""
**CutHalf** is a function that split a group of point into two subgroups with respect to a prescribed center. <br>
**Inputs:**
1. X::Array{Float64,2}, dimension = d x N
2. Center::Int

**Output:**
a dictionary <br>
**keys:** “With Center”, “Without Center” <br> 
**values:** arrays of integers storing the points in each group <br>
"""
function CutHalf(X::Array{Float64,2}, Center::Int)
    ## Findout the point closest to Center
    Diff = X.-X[:,Center] ## compute the difference to Center
    Dist = [norm(Diff[:,i]) for i=1:size(X,2)-1] ## compute the distances to Center
    Dist[Center] = Inf ## set the distance of Center to itself as Inf (to remove Center)
    Closest = findmin(Dist)
    ClosestPt = X[:, Closest[2]]
    ClosestDist = Closest[1]

    Vector = ClosestPt-X[:,Center]
    MidPt = (ClosestPt+X[:,Center])/2

    InnerProds = sortslices([X'*Vector collect(1:size(X,2))], dims = 1)
    MidInnerProd = Vector'*MidPt

    BdIndex = findlast(InnerProds[:,1].<MidInnerProd) ## BdIndex = Boundary Index
    C_Center = Array{Int,1}(InnerProds[1:BdIndex, 2])
    C_Closest = Array{Int,1}(InnerProds[BdIndex:end, 2])
    Dict("With Center"=>C_Center, "Without Center"=>C_Closest)
end