using LinearAlgebra
include("Pseudo_kNN.jl")
"""
**Note**: kNNRWICDist = kNN random walk inter-cluster distance

**kNNRWICDist** is a function implementing the idea of "random walk" and "kNN (k nearest neighbors)" 
to compute the distance between two clusters. <br>
**Inputs**:
1. **C1**, the coordinates of the points in cluster 1 (columns = points)
2. **C2**, the coordinates of the points in cluster 2 (columns = points)
3. **k**, the integer used for kNN
4. (Optional) **PtsOrd1**, the order matrix obtained by ordering the values of each row in C1; 
    this will be computed if not used as input; 
    purpose: if pre-computed, computational allocations and time can be saved
5. (Optional) **PtsOrd2**, the order matrix obtained by ordering the values of each row in C2; 
    this will be computed if not used as input; 
    purpose: if pre-computed, computational allocations and time can be saved
**Output**: a triple (P1,P2,dist) where
1. **P1**, label for the closest point in cluster 1
2. **P2**, label for the closest point in cluster 2
3. **dist**, the distance bewteen the input clusters
"""
function kNNRWICDist(C1::Array{Float64,2}, C2::Array{Float64,2}, 
        k=min(20,size(C1,2), size(C2,2))::Int; 
        PtsOrd1 = (Sample2Order(C1))::Array{Int,2},  PtsOrd2 = (Sample2Order(C2))::Array{Int,2})

    ## Set randomly the starting points in each cluster
    P1 = rand(collect(1:size(C1,2)), 1)[1]
    P2 = rand(collect(1:size(C2,2)), 1)[1];
    dist = norm(C1[:,P1]-C2[:,P2]) ## distance b/w the current two points
    ## dist_hist = [copy(dist)] ## distance history
    ## P1_hist = [copy(P1)] ## P1 history
    ## P2_hist = [copy(P2)]; ## P2 history
    
    P1_copy = 0
    P2_copy = 0;
    
    while (P1!=P1_copy)||(P2!=P2_copy)

        ## fix P2 and explore kNN of P1 for P1's random walk
        kNNP1 = setdiff(Pseudo_kNN(C1, k, P1, Pts_Orders = PtsOrd1),P1)
        P1_copy = copy(P1)
        while true
            if length(kNNP1)==0
                P1 = P1_copy
                break
            end
            P1_new = sample(kNNP1)
            dist_new = norm(C1[:,P1_new]-C2[:,P2])
            if dist_new<dist
                dist = copy(dist_new)
                ## push!(dist_hist, dist)
                P1 = copy(P1_new)
                ## push!(P1_hist, P1)
                break
            else
                kNNP1 = setdiff(kNNP1, P1_new)
            end
        end

        ## fix P1 and explore kNN of P2 for P2's random walk
        kNNP2 = setdiff(Pseudo_kNN(C2, k, P2, Pts_Orders = PtsOrd2),P2)
        P2_copy = copy(P2)
        while true
            if length(kNNP2)==0
                P2 = P2_copy
                break
            end
            P2_new = sample(kNNP2)
            dist_new = norm(C2[:,P2_new]-C1[:,P1])
            if dist_new<dist
                dist = copy(dist_new)
                ## push!(dist_hist, dist)
                P2 = copy(P2_new)
                ## push!(P2_hist, P2)
                break
            else
                kNNP2 = setdiff(kNNP2, P2_new)
            end
        end
    end
    return (P1,P2,dist)
end