using LinearAlgebra ## "dot"
using QHull ## "chull"
## using Plots
## plotly()

## This function computes, given a group of points, a subgroup representing its boundary
## Inputs: 
## (1) G = N x 2 matrix; each row is a point in the group
## (2) ratio, set as 0.05 by default, the ratio of the points used to represent each edge of the boundary
function Boundary(G::Array{Float64,2}, ratio = 0.05::Float64) ## G = Group (of points), N x 2
    ch = chull(G)
    ## ch.points         # original points
    ## ch.vertices       # indices to line segments forming the convex hull
    ## ch.simplices;      # the simplexes forming the convex hull
    ## show(ch) 
        
        
    ## ratio = 1/50
    ## plot for illustration
    ## scatter(G[:,1], G[:,2], markersize = 1, label = "points")
    ## scatter!(G[ch.vertices,1], G[ch.vertices,2], label = "vertices")
    Bds = ch.simplices 
    Bd_Pts = ch.vertices
    for b = 1:length(Bds)
        vector_b = G[Bds[b][1],:]-G[Bds[b][2],:] ## the vector of the boundary b
        normal_b = [-vector_b[2], vector_b[1]] ## a vector normal to the boundary b vector
        ## move vector_b orthogonally and find out the intersected bar
        bd_b_para = G*vector_b 
        Range_b_para = G[ch.simplices[b],:]*vector_b
        pts_b_para = findall((G*vector_b.<=maximum(Range_b_para)).&(minimum(Range_b_para).<=G*vector_b))
        N = Int(round(ratio*length(pts_b_para)))
        Values_Labels = sortslices([G[pts_b_para,:]*normal_b pts_b_para], dims = 1)
        Values = Values_Labels[:,1]
        Labels = Values_Labels[:,2]
        Bd_Pts_N = 0
        if abs((Values[1]-Values[2])/Values[2])<1.0e-5
            Bd_Pts_N = Array{Int,1}(Labels[1:N])
        else
            Bd_Pts_N = Array{Int,1}(Labels[length(Labels)-N+1:length(Labels)])
        end
        Bd_Pts = union(Bd_Pts, Bd_Pts_N)
        ## plot for sanity check
        ## plot!(G[Bds[b],:][:,1], G[Bds[b],:][:,2], label = "Bd $b")
        ## scatter!(G[Bd_Pts_N,1], G[Bd_Pts_N,2], label = "Bd $b points")
    end
    ## scatter!()
    Bd_Pts
end


## This function computes by brute force the minimum pairwise distances between two groups of points
## Input: G1, G2, N x d
## Output: 
## (1) the pair of points in G1 and G2, resp, achieving the minimum
## (2) the minimum distance
function Inter_Distance(G1::Array{Float64,2}, G2::Array{Float64,2})
    Dist2 = [sum((G1[i,:]-G2[j,:]).^2) for i=1:size(G1,1), j = 1:size(G2,1)] ## distance^2
    G1_G2_Min = findmin(Dist2)
    ## Min_Index = G1_G2_Min[2]
    ## Min_Dist = sqrt(G1_G2_Min[1])
    return (G1_G2_Min[2], sqrt(G1_G2_Min[1]))
end

"""
**Convex_Boundary_Inter_Distance** is a function computing an "approximate" minimum distance bewteen two groups of points. <br>
**Details:** <br>
First, compute a subgroup for each group representing the boundaries. <br>
Second, compute directly the minimum among distances between pairs of points from the two groups, resp. <br>
**Inputs:**
1. G1 = N1 x 2 matrix; each row is a point in group G1
2. G2 = N2 x 2 matrix; each row is a point in group G2
3. ratio = 0.05, the ratio in the function "Boundary"
**Output:** a dictionary with 3 keys <br>
**keys:** ("Group1", "Group2", "D_min")
**values:**(the points in each group achieving the minimum distance, the so-computed minimum distance).
"""
function Convex_Boundary_Inter_Distance(G1::Array{Float64,2}, G2::Array{Float64,2}, ratio = 0.05::Float64)
    Bd1_Label = Boundary(G1, ratio)
    Bd2_Label = Boundary(G2, ratio)
    G1_Bd1 = G1[Bd1_Label,:]
    G2_Bd2 = G2[Bd2_Label,:]
    (NewLabel, Dist_Min) = Inter_Distance(G1_Bd1, G2_Bd2)
    return Dict("Group1"=>Bd1_Label[NewLabel[1]], "Group2"=>Bd2_Label[NewLabel[2]], "D_min"=>Dist_Min)
end