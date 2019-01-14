using LinearAlgebra
"""
**Mode** is a function computing the local maximal positions of a function in an assigned Range.
**Inputs:**
1. a function f:R^d→R
2. Range = [a_{11} a_{12}; a_{21} a_{22}; … ; a_{d1} a_{d2}]::Array{Float64,2}, dimension d x 2; this is the range of each variable of the function in 1. to be explore
3. k::Int, a positive integer, where kNN is based to seek mode
4. N::Int, number of uniform points to be put in Range to be tested as modes via kNN
**Output:**
the collection of points to be used as modes of f
"""
function Mode(f, Range::Array{Float64,2}; N=1000::Int, k=20::Int)
    ## generate N random points in [0,1]^d
    d = size(Range,1)
    RandPts = rand(N,d); RandPts = [RandPts[i,:] for i=1:size(RandPts,1)];
    ## Define the function for rescaling the points into Range
    Rescale(X) = (Range[:,2]-Range[:,1]).*X.+Range[:,1];
    ## Rescale the points into Range
    NewSample = Rescale.(RandPts);
    ## Evaluate f on the points
    f_Values = f.(NewSample);
    ## compute the kNN of each point 
    ## (Purpose: use kNN to find out whether each point is a local maximum)
    ## Remark: this part may be improved by more advanced "Mode Seeking" algorithm
    ## Compute the distance matrix
    Dist = zeros(N,N)
    for i=1:N
        for j=i+1:N
            Dist[i,j] = norm(NewSample[i,:]-NewSample[j,:])
            Dist[j,i] = Dist[i,j]
        end
    end
    Dist
    kNN_Dict = Dict(i=>Array{Int}(sortslices([Dist[i,:] collect(1:N)], dims = 1)[2:k+1,2]) for i=1:N);
    ## Find out the peaks using kNN
    Peaks = []
    for i=1:N
        if sum([f_Values[j] for j in kNN_Dict[i]].<f_Values[i])==k
            push!(Peaks,i)
        end
    end
    Peaks;
    Peaks = NewSample[Peaks]
    return Peaks
end