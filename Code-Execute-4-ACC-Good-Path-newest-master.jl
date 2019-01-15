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

global N_c = 2*size(Data, 2)

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
        Start = Int[] ## the start point of the improved path
        L_Imp = Float64[] ## Length Improved
        Path_new = Array{Int64,1}[] ## the improved path
        for file in Path_tasks
            Read_file = readdlm("Temp//$(file)")
            push!(Start, Read_file[2,1])
            push!(L_Imp, Read_file[4,1])
            push!(Path_new, Read_file[6:end,1])
        end
        L_Imp_Ord = Array{Int, 1}(sortslices([L_Imp collect(1:N_task)], dims=1, rev=true)[:,2])
        while L_Imp_Ord!=[]
            Cand = L_Imp_Ord[1] ## Candidate
            GoodPath = CSV.read(Path_File*".csv");
            global GoodPath = Array{Int, 1}(GoodPath[:Path]);
            a = Start[Cand]
            b = a+k-1
            GoodPath[a:b] = Path_new[Cand]
            df = DataFrame([GoodPath], [:Path]); ## store as dataframe type and add the column name :Path
            CSV.write(Path_File*".csv", df)
            Improve = L_Imp[Cand]
            try 
                Imp_total = readdlm(Path_File*"_Improve_total.txt")[1]
                Imp_total = Imp_total + Improve
                writedlm(Path_File*"_Improve_total.txt", Imp_total)
            catch
                writedlm(Path_File*"_Improve_total.txt", Improve)
            end
            L_Imp_Ord = setdiff(L_Imp_Ord, L_Imp_Ord[(abs.(Start[L_Imp_Ord].-Start[Cand])).<k])
        end
        ## remove the Path_tasks files
        for file in Path_tasks
            rm("Temp//$(file)")
        end
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
    
    writedlm(Path_File*"_Progress_master_$(i)_of_$(N_c).txt",0)
    if i!=1
        rm(Path_File*"_Progress_master_$(i-1)_of_$(N_c).txt")
    end
    
    global i = i+1
    
    ## if the new path shortens the path length, save the path in Temp
    if L_n<L_o
        Improve = L_o-L_n
        writedlm("Temp//Path_master.txt", [["Start", a, "Improved_Length", Improve, "Path"]; GoodPath[a:b][Path_a]])
    end
end