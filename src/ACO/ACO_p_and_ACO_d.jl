using LinearAlgebra ## for the function "norm"
using StatsBase ## for function "sample"

"""
ACO_p is a function implementing **ACO (Ant Colony Optimization)** on a matrix of coordinates of points. The purpose is to find a path going through each point exactly once and achieving minimum total travelling distance. <br>

**Inputs**: <br>
(1) **Pts**: an N x d matrix; each row represents the coordinates of a point <br>
(2) **Origin**: the starting point, **Goal**: the goal <br><br>
(3) **N_I**: number of iteration; default value = 1 <br>
(4) **alp**: alpha, **bet**: beta; default value: alp = 1.0, bet = 1.0; these are hyperparameters controlling the influence of distance and remaining pheromone on the path, repectively <br>
(5) **rho**: evaporation rate; default value: rho = 0.3 <br>
(6) **Q**: the total amount of pheromone an ant carries; default value: Q = 10 <br>

**Output**: an array of integers representing the order of the points in which the path goes through. <br>
"""
function ACO_p(;Pts::Array{Float64,2}, Origin::Int, Goal::Int, Na = 1000::Int, N_I = 1::Int, alp = 1.0::Float64, bet = 1.0::Float64, 
        rho = 0.3::Float64, Q = 10.0::Float64)
    N = size(Pts,1)
    ## compute the distance matrix
    Dist = [norm(Pts[i,:].-Pts[j,:]) for i=1:N, j=1:N]; ## the distance matrix of the points
    ## Dictionary for collecting the best result in each iteration
    Iteration_Dict = Dict()
    for i = 1:N_I
        Tau = 1/(N-1)*ones(N,N)-1/(N-1)*Matrix{Float64}(I,N,N); ## the prior transition probability
        Best_L = Inf ## the best (shortest) length
        BestPath = 0 ## the best (shortest) path
    
        L = 0 ## variable for stopping criterion
        L_previous = Inf ## variable for stopping criterion
        a = 0
        while (abs(L-L_previous)>1.0e-7)&&(a<Na)
            ## The interior of this while loop may be written as a function.
            a = a+1
            L_previous = copy(L)
            AP = AntPath(Origin, Goal, N, Dist, alp, bet, Tau, Q, rho)
            Tau = AP[1]
            path_a = AP[2]
            L = AP[3]
            
            ## store the best record
            if L<Best_L
                Best_L = copy(L)
                BestPath = copy(path_a)
            end
        end
        
        Iteration_Dict[i] = (Best_L, BestPath)
        ## println(Best_L, BestPath)
    end
    
    ## Find out the best result among all iterations
    Best_I = findmin([Iteration_Dict[i][1] for i=1:N_I])[2]
    
    return Iteration_Dict[Best_I]
end


"""
This function implements **ACO (Ant Colony Optimization)** on a matrix of distances. The purpose is to find a path going through each point exactly once and achieving minimum total travelling distance. <br>
**Inputs**: <br>
(1) **Dist**: the distance matrix <br>
(2) **Origin**: the starting point, Goal = the goal <br>
(3) **N_I**: number of iteration; default value = 100 <br>
(4) **alp**: alpha, bet = beta; these are hyperparameters controlling the influence of distance and remaining pheromone on the path <br>
(5) **rho**: evaporation rate, Q = the total amount of pheromone an ant carries <br>
**Output**: an array of integers representing the order of the points in which the path goes through. <br>
"""
function ACO_d(;Dist::Array{Float64,2}, Origin::Int, Goal::Int, Na=1000::Int, N_I = 1::Int, 
        alp = 1.0::Float64, bet = 1.0::Float64, rho = 0.3::Float64, Q = 1.0::Float64)
    N = size(Dist,1)
    ## Dictionary for collecting the best result in each iteration
    ## Path_History = Dict() ## save the history
    ## Length_History = Dict() ## save the history dictionary
    Iteration_Dict = Dict()
    for i = 1:N_I
        Tau = 1/(N-1)*ones(N,N)-1/(N-1)*Matrix{Float64}(I,N,N); ## the prior transition probability
        Best_L = Inf ## the best (shortest) length
        BestPath = 0 ## the best (shortest) path
        ##j = 0 ## indicator of Path_History
        L = 0 ## variable for stopping criterion
        L_previous = Inf ## variable for stopping criterion
        a = 0
        while (abs(L-L_previous)>1.0e-7)&&(a<Na)
            ## The interior of this while loop may be written as a function.
            a = a+1
            L_previous = copy(L)
            AP = AntPath(Origin, Goal, N, Dist, alp, bet, Tau, Q, rho)
            Tau = AP[1]
            path_a = AP[2]
            L = AP[3]
            ##j = j+1
            ##Path_History[j] = path_a
            ##Length_History[j] = L
            ## store the best record
            if L<Best_L
                Best_L = copy(L)
                BestPath = copy(path_a)
            end
        end
        
        Iteration_Dict[i] = (Best_L, BestPath)
        ## println(Best_L, BestPath)
    end
    
    ## Find out the best result among all iterations
    Best_I = findmin([Iteration_Dict[i][1] for i=1:N_I])[2]
    
    return Iteration_Dict[Best_I] ## , Path_History, Length_History)
end

"""

"""
function AntPath(Origin::Int, Goal::Int, N::Int, Dist::Array{Float64,2}, 
        alp::Float64, bet::Float64, Tau::Array{Float64,2}, Q::Float64, rho::Float64)
    L = 0
    Cand = setdiff(collect(1:N),[Origin, Goal]) ## the candidates
    CP = copy(Origin) ## cp =  current point
    path_a = Int[Origin]
            
    if Origin!=Goal
        for p = 2:N-1
            w = aweights((Tau[CP,Cand].^alp).*((Dist[CP,Cand].^(-1)).^bet))
            CP = sample(Cand,w)
            Cand = setdiff(Cand,[CP])
            push!(path_a,CP)
        end
        push!(path_a, Goal)
        L = sum([Dist[path_a[j],path_a[j+1]] for j=1:N-1]) ## total length of path_a
    else
        for p = 2:N
            w = aweights((Tau[CP,Cand].^alp).*((Dist[CP,Cand].^(-1)).^bet))
            CP = sample(Cand,w)
            Cand = setdiff(Cand,[CP])
            push!(path_a,CP)
        end
        push!(path_a, Goal)
        L = sum([Dist[path_a[j], path_a[j+1]] for j=1:N]) ## total length of path_a
    end
    path_a
    
    Tau = Tau*(1-rho) ## evaporation update
    ## Pheromone update
    PheroPerUnit = Q/L
    if Origin!=Goal
        for j = 1:N-1
            Tau[path_a[j], path_a[j+1]] = Tau[path_a[j], path_a[j+1]] + PheroPerUnit ## Pheromone update
        end
    else
        for j = 1:N
            Tau[path_a[j], path_a[j+1]] = Tau[path_a[j], path_a[j+1]] + PheroPerUnit ## Pheromone update
        end
    end
    Tau
    
    return (Tau, path_a, L)
end