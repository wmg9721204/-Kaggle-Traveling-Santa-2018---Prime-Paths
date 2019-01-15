using DataFrames
using CSV
Cities = CSV.read("cities.csv")
global Data = Array{Float64,2}([Cities[:X]'; Cities[:Y]']);
## global Data = rand(2,1000)
################################################################################################
include("src//ParaSelectACO.jl")
## Hyperparameters for ParaSelectACO
global Range = [0.0 5.0; 0.0 5.0; 0.0 1.0; 0.0 30.0] ## alpha/beta/rho/Q for ACO (in order)
global N_sample = 500; ## Number of times for randomly generating hyper-paramters
#################################################################################
include("src//kNNRWICDist.jl")
############################################################
## Hyper-parameters
global k = 18 ## upper bound for tree sub-clustering
global N_d = 10 ## retrying times of subclustering
#############################################################
C = collect(1:size(Data,2))
global Sub_Clusters = Array{Int,1}[C]
global Bottom_Clusters = Array{Int,1}[]
global Path = Array{Int,1}[C] ## the path of clusters
global In_Out = Array{Int,1}[[1,1]] ## the in/out-point corresponding to each cluster in Path
###########################################################################################
using Clustering
## (Initializing step)
println("Initialization Step: applying ACO on layer-1 sub-clusters")
for init = 1
    Path_copy = copy(Path)
    global Path = Array{Int,1}[]
    In_Out_copy = copy(In_Out)
    global In_Out = Array{Int,1}[]
    
    In_Out_C = In_Out_copy[1]

    N_C = min(k, round(Int, length(C)/k, RoundUp))
    global Sub_Clusters = setdiff(Sub_Clusters, [C])
    R = kmeans(Data[:,C], N_C) ##; maxiter = 2000, display=:iter) ## R = Result
    A = assignments(R) ## the assignments of the points

    C_subs = [C[A.==j] for j=1:N_C]
    C_in = C[In_Out_C[1]]
    C_out = C[In_Out_C[2]]
    O = findfirst([(C_in in sub) for sub in C_subs])
    G = findfirst([(C_out in sub) for sub in C_subs])

    Dist_subs = zeros(N_C, N_C)
    Label_subs = Array{Tuple{Int,Int}, 2}(undef, N_C, N_C)
    for j=1:N_C
        Label_subs[j,j] = (0,0)
    end

    append!(Sub_Clusters, C_subs)
    for j=1:N_C-1
        for k = j+1:N_C
            Sub_j = C_subs[j]
            Sub_k = C_subs[k]
            KNND = kNNRWICDist(Data[:,Sub_j], Data[:,Sub_k])
            Dist_subs[j,k] = KNND[3]
            Dist_subs[k,j] = KNND[3]
            Label_subs[j,k] = (KNND[1], KNND[2])
            Label_subs[k,j] = (KNND[2], KNND[1])
        end
    end

    PSACO = ParaSelectACO(Range, N_sample, Dist_subs, O, G; Na=200) ## Na = number of ants used to ACO
    append!(Path, C_subs[PSACO["Best_Path"]][1:end-1])
    global Bottom_Clusters = Bottom_Clusters
    P = PSACO["Best_Path"]
    push!(In_Out, [Label_subs[P[end-1], P[end]][2], Label_subs[O, P[2]][1]])
    for i = 2:length(P)-1
        push!(In_Out, [Label_subs[P[i-1], P[i]][2], Label_subs[P[i], P[i+1]][1]])
    end
    println("Initialization completed!!")
end
#####################################################################################
include("src//CutHalf2.jl")
include("src//Nearest.jl")
#######################################################################
## (Loop step)
println("Loop Step: applying ACO on non-bottom sub-clusters")
global T= 0
while length(Sub_Clusters)!=0
    Path_copy = copy(Path)
    global Path = Array{Int,1}[]
    In_Out_copy = copy(In_Out)
    global In_Out = Array{Int,1}[]
    for i=1:length(Path_copy)
        C = Path_copy[i]
        In_Out_C = In_Out_copy[i]
        if C in Bottom_Clusters
            push!(Path, C)
            push!(In_Out, In_Out_C)
        else        
            N_C = min(k, round(Int,length(C)/k, RoundUp))
            if N_C==1
                push!(Path, C)
                push!(In_Out, In_Out_C)
                global Sub_Clusters = setdiff(Sub_Clusters, [C])
                push!(Bottom_Clusters, C)
            else
                global T = T+1
                println(T)
                N = 1
                global Sub_Clusters = setdiff(Sub_Clusters, [C])
                O = 0
                G = 0
                C_in = 0
                C_out = 0
                C_subs = Array{Int,1}[]
                while N<=N_d
                    R = kmeans(Data[:,C], N_C) ##; maxiter = 2000, display=:iter) ## R = Result
                    A = assignments(R) ## the assignments of the points
                    Nc = nclusters(R) ## number of clusters
                    Ct = counts(R); ## size of each cluster
                    
                    C_subs = [C[A.==j] for j=1:N_C]
                    C_in = C[In_Out_C[1]]
                    C_out = C[In_Out_C[2]]
                    O = findfirst([(C_in in sub) for sub in C_subs])
                    G = findfirst([(C_out in sub) for sub in C_subs])
                    if O!=G
                        break
                    elseif (O==G)&&(length(C)==1)
                        N = N_d+1
                    else
                        N = N+1
                        println("Repeat = $(N-1)")
                    end
                end
                
                ## if k-means cannot separate C_in and C_out, implement the naive brute force CutHalf2
                if (N==N_d+1)&&(C_in!=C_out) ## 
                    println("Execute CutHalf2")
                    N_C = 2
                    CH2 = CutHalf2(Data[:,C], In_Out_C[1], In_Out_C[2])
                    C_subs = [C[CH2[1]], C[CH2[2]]]
                    O = 1
                    G = 2
                elseif (N==N_d+1)&&(C_in==C_out)&&(length(C)!=1)
                    println("Execute CutHalf")
                    N_C = 2
                    CH = CutHalf2(Data[:,C], In_Out_C[1], Nearest(Data[:,C], In_Out_C[1]))
                    C_subs = [C[CH[1]], C[CH[2]]]
                    O = 1
                    G = 2
                    C_out = C[Nearest(Data[:,C], In_Out_C[1])]
                end
                
                if O==G
                    push!(Bottom_Clusters, C)
                    push!(Path, C)
                    push!(In_Out, In_Out_C)
                else
                    append!(Sub_Clusters, C_subs)
                    Dist_subs = zeros(N_C, N_C)
                    Label_subs = Array{Tuple{Int,Int}, 2}(undef, N_C, N_C)
                    for j=1:N_C                    
                        Label_subs[j,j] = (0,0)
                    end
                    
                    for j=1:N_C-1
                        for k = j+1:N_C
                            Sub_j = C_subs[j]
                            Sub_k = C_subs[k]
                            KNND = kNNRWICDist(Data[:,Sub_j], Data[:,Sub_k])
                            Dist_subs[j,k] = KNND[3]
                            Dist_subs[k,j] = KNND[3]
                            Label_subs[j,k] = (KNND[1], KNND[2])
                            Label_subs[k,j] = (KNND[2], KNND[1])
                        end
                    end
                    PSACO = ParaSelectACO(Range, N_sample, Dist_subs, O, G; Na=200)
                    append!(Path, C_subs[PSACO["Best_Path"]])
                    global Bottom_Clusters = Bottom_Clusters
                    P = PSACO["Best_Path"]
                    push!(In_Out, [findfirst(C_subs[O].==C_in), Label_subs[O, P[2]][1]])
                    for i=2:length(P)-1
                        push!(In_Out, [Label_subs[P[i-1], P[i]][2], Label_subs[P[i], P[i+1]][1]])
                    end
                    push!(In_Out, [Label_subs[P[end-1], P[end]][2], findfirst(C_subs[G].==C_out)])
                end
            end
        end
    end
end
println("Loop step completed")
println("Path length = $(length(Path))")
using DelimitedFiles
writedlm("Path-length.txt", (length(Path)))
using FileIO
save("Path_In_Out_$(k)_$(N_d).jld2", Dict("Path"=>Path, "In_Out"=>In_Out))
#############################################################################
