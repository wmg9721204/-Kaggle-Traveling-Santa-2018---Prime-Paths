using Clustering
"""
**TreeSubCluster** is a function that implements 
a tree structure idea for continuously subclustering layer by layer 
such that both <br>
(1) the size of each bottom subcluster and <br>
(2) the number of subclusters of each subcluster <br>
is less than or equal to k.
**Inputs:**
1. X, a d x N matrix, where each column is a point in dimension d
2. k, an integer, the upper bound for the size and number of subclusters.

**Output:** a pair of dictionaries, where
1. the first item stores the labels of points in each cluster, and 
2. the second item stores the number of subclusters which each cluster has.
"""
function TreeSubCluster(X::Array{Float64,2}, k::Int)
    Layer = 0 ## layer indicator
    
    ## Initialize with a k cluster
    R = kmeans(X, k) ##; maxiter = 2000, display=:iter) ## R = Result
    A = assignments(R) ## the assignments of the points
    Nc = nclusters(R) ## number of clusters
    C = counts(R); ## size of each cluster
    
    ## This will store the indices of the points in each cluster
    Cluster_Dic = Dict([i]=>findall(A.==i) for i=1:k) ##
    Cluster_Dic[Int[]] = collect(1:size(X,2))
    ## This will store the number of subclusters of each cluster (0 means no subcluster)
    SubSize_Dic = Dict([i]=>0 for i=1:k)
    SubSize_Dic[Int[]] = k
    
    
    Stop = false ## indication of stopping
    
    while !Stop
        Layer = Layer + 1
        Stop = true ## default the stopping rule as true
        for key in keys(Cluster_Dic)
            if (length(key)==Layer)&(length(Cluster_Dic[key])>k)
                ## number of subclusters to subdivide
                N_c = min(round(Int, length(Cluster_Dic[key])/k, RoundUp), k)
                ## record this number
                SubSize_Dic[key] = N_c ## N_c subclusters
                ## apply kmeans
                R_sub = kmeans(X[:,Cluster_Dic[key]], N_c)
                ## call the assignments
                A_sub = assignments(R_sub)
                ## call the counts (sizes of the subclusters)
                C_sub = counts(R_sub)
                if maximum(C_sub)>k ## if there is a subcluster of size >k, continue the process
                    Stop = false
                end
                for i=1:N_c
                    Cluster_Dic[[key;i]] = (Cluster_Dic[key])[findall(A_sub.==i)]
                    if C_sub[i]<=k
                        SubSize_Dic[[key;i]]=0 ## no subcluster
                    end
                end
            elseif (length(key)==Layer)&(length(Cluster_Dic[key])<=k)
                SubSize_Dic[key] = 0 ## no subcluster
            end
        end
        Cluster_Dic
    end
    return (Cluster_Dic, SubSize_Dic)
end