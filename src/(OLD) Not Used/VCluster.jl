using LinearAlgebra
"""
**VCluster (Voronoi Clustering)** is a function implementing the Voronoi tesselation for clustering. <br>
**Inputs:**
1. Centers:: Array{Float64,2}, dim = d x Nc; Nc = number of centers
2. Pts::Array{Float64,2}, dim = d x N; N = number of points

**Output:** 
a dictionary VC_Dict; VC_Dict[i] = the indices of the points classified to cluster with center Centers[:,i]
"""
function VCluster(Centers::Array{Float64,2}, Pts::Array{Float64,2})
    ## Classify each city point to the closest peak
    Nc = size(Centers,2)
    N = size(Pts,2)
    VC_Dict = Dict(k=>Int[] for k=1:Nc)
    for i = 1:N
        Diff_i = Pts[:,i].-Centers
        C_i = Int(sortslices([[norm(Diff_i[:,j]) for j = 1:Nc] collect(1:Nc)], dims = 1)[1,2]) ## C_i = the cluster city i belongs to
        push!(VC_Dict[C_i],i)
    end
    VC_Dict
end