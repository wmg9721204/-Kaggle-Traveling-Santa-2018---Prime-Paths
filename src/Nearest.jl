using LinearAlgebra
"""
Nearest is a function computing the nearest neighbor (excluding itself) of a point in a point cloud.
"""
function Nearest(X::Array{Float64,2}, a::Int)
    Dist = [norm(X[:,i]-X[:,a]) for i=1:size(X,2)]
    Dist[a] = Inf
    NP = findmin(Dist)[2] ## Nearest Point
end