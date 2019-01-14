## This is for master processor
include("src//ParaSelectACO.jl");
include("src//L_o_L_n.jl");

using DataFrames
using CSV
Cities = CSV.read("cities.csv")
global Data = Array{Float64,2}([Cities[:X]'; Cities[:Y]']);

global Path_File = "Good-Path-newest"

using LinearAlgebra ## for the function "norm"
using StatsBase ## for function "sample"

global k = 20
global Range = [0.0 5.0; 0.0 5.0; 0.0 1.0; 0.0 30.0]
global N_sample = 500;
global Imp_total = 0.0 ## improve total

global N_c = size(Data, 2)

## create a directory "Temp" (for multi-line processing)
try
    mkdir("Temp")
catch
end

using Primes
using FileIO
using DelimitedFiles

global i = 1

while i<=N_c    
    Path_tasks = readdir("Temp")
    N_task = length(Path_tasks)
    if N_task!=0
        ## for non-master processors, simply "continue"
        continue
    end
            
    GoodPath = CSV.read(Path_File*".csv");
    global GoodPath = Array{Int, 1}(GoodPath[:Path]);
    
    a = sample(collect(1:size(Data,2)-k+2))
    b = a+k-1
    Pts = Data[:,GoodPath[a:a+k-1].+1]
    D = zeros(k,k)
    for j=1:k-1
        for l = j+1:k
            D[j,l] = norm(Pts[:,j]-Pts[:,l])
            D[l,j] = D[j,l]
        end
    end
    
    ###########################################################################
    L_o = Old_Length(a, k, D, GoodPath)

    ###########################################################################    
    PSACO = ParaSelectACO(Range, N_sample, D, 1, k; Na = 200::Int)
    Path_a = PSACO["Best_Path"]
    ## total length of the new path
    L_n = New_Length(a, k, D, GoodPath, Path_a)
    
    writedlm(Path_File*"_Progress_90_$(i)_of_$(N_c).txt",0)
    if i!=1
        rm(Path_File*"_Progress_90_$(i-1)_of_$(N_c).txt")
    end
    
    global i = i+1
    
    ## if the new path shortens the path length, save the path in Temp
    if L_n<L_o
        Improve = L_o-L_n
        writedlm("Temp//Path_90.txt", [["Start", a, "Improved_Length", Improve, "Path"]; GoodPath[a:b][Path_a]])
    end
end
