include("ACO//ACO_p_and_ACO_d.jl") ## "ACO_p", "ACO_d"

"""
**ParaSelectACO** is a function that selects appropriate parameters for ACO.
"""
function ParaSelectACO(Range::Array{Float64, 2}, N_sample::Int, D::Array{Float64,2}, O::Int, G::Int; Na=200::Int)
    RP = RandPts(Range, N_sample)
    Best_Length = Inf
    Best_Path = Int[]
    Best_Para = zeros(4)
    History = Float64[]
    for i=1:N_sample
        AP = ACO_d(Dist = D, Origin = O, Goal = G, alp = RP[1, i], bet = RP[2, i], rho = RP[3, i], Q = RP[4, i], Na = Na)
        push!(History, AP[1])
        if AP[1]<Best_Length
            Best_Length = AP[1]
            Best_Path = AP[2]
            Best_Para = RP[:,i]
        end
    end
    return Dict("Best_Length"=>Best_Length, "Best_Path"=>Best_Path, 
        "Length_History"=>History, "Best_Para"=>Best_Para)
end

"""
**RandPts** is a function that randomly uniformly generates m points in dimension size(Range,2) inside Range. <br>
Inputs: <br>
m: number of random points to generate <br>
Range: dim x 2 matrix; the d-th row is the range of the d-th coordinate <br>
Output: <br>
an dim x m matrix; each column is a desired random vector. <br>
"""
function RandPts(Range::Array{Float64,2}, m::Int)
    ## dim = size(Range,1)
    ## randPts = rand(dim,m)
    ## Coeff = (Range[:,2].-Range[:,1])
    ## Intercept = Range[:,1]
    ## randPts = ((Range[:,2].-Range[:,1]).*rand(size(Range,1),m)).+Range[:,1]
    return ((Range[:,2].-Range[:,1]).*rand(size(Range,1),m)).+Range[:,1]
end