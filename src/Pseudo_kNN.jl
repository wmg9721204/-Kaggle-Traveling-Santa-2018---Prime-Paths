## Sample2Order is a function transforming a numerical matrix entries into their orders row-wisely
function Sample2Order(Sample::Array{Float64,2})
    ## transform the points into orders
    Pts_Orders = zeros(Int, size(Sample))
    N = size(Sample,2)
    d = size(Sample,1)
    for i = 1:d
        Pts_Seq = sortslices([Sample[i,:] collect(1:N)], dims = 1)
        Orders = Array{Int,1}(sortslices([Pts_Seq[:,2] collect(1:N)], dims = 1)[:,2])
        Pts_Orders[i,:] = Orders
    end
    return Pts_Orders
end

"""
**Pseudo_kNN** is a function implementing an efficient algorithm computing a pseudo kNN
"""
function Pseudo_kNN(Sample::Array{Float64,2}, k::Int, p::Int; Pts_Orders=Sample2Order(Sample)::Array{Int, 2})
    d = size(Pts_Orders, 1) ## dimension of the sample points
    N = size(Pts_Orders, 2) ## size of the sample
    if k>N
        error("The k in kNN should be less than or equal to the sample size!!!")
    end
    
    ## Use "Bisection Method" to find the desired kNN 
    Candidates = Int[]
    Lower = 0
    Upper = size(Pts_Orders,2)
    l = round(Int,size(Pts_Orders,2)/2, RoundUp) ## length of integral cubical side

    ## Initialize the procedure
    Test = (Pts_Orders[:,p].-l).<Pts_Orders.<(Pts_Orders[:,p].+l)
    Prod = Test[1,:]
    for j=2:d
        Prod = Prod.*(Test[j,:])
    end
    Candidates = findall(Prod)

    ## Use "Bisection Method" to find the desired kNN
    while (length(Candidates)!=k)
        if length(Candidates)>k
            Upper = round(Int, (Upper+Lower)/2, RoundUp)
            ## println("LowerUpper = $((Lower, Upper))")
        else  ## if length(Candidates)<k
            Lower = round(Int, (Upper+Lower)/2, RoundDown)
            ## println("LowerUpper = $((Lower, Upper))")
        end
    
        ## If the kNN cannot be achieved, break the while loop
        if (Upper-Lower)<=1
            break
        end
    
        l = round(Int, (Upper+Lower)/2, RoundUp)
        ## println(l)
    
        Test = (Pts_Orders[:,p].-l).<Pts_Orders.<(Pts_Orders[:,p].+l)
        Prod = Test[1,:]
        for j=2:d
            Prod = Prod.*(Test[j,:])
        end
        Candidates = findall(Prod)
        ## println("k = $(length(Candidates))")
    end
    return Candidates
end

"""
Pseudo_kNN_Dict computest the whole kNN dictionary
"""
function Pseudo_kNN_Dict(Sample::Array{Float64,2}, k::Int; Pts_Orders=Sample2Order(Sample)::Array{Int, 2})
    kNN_Dict = Dict{Int, Array{Int,1}}()
    for p = 1:size(Pts_Orders, 2)
        kNN_Dict[p] = Pseudo_kNN(Pts_Orders, k, p)
    end
    return kNN_Dict
end