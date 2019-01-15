println("Implement Naive ACO (not considering 10-step constratint): applying ACO on bottom sub-clusters")
global k = 18
global N_d = 10
using FileIO
global d = load("Path_In_Out_$(k)_$(N_d).jld2")
global Path = d["Path"]
global In_Out = d["In_Out"]

## This part is in case termination before completing the code is necessary. 
try
    D_Sol_naive_Done = load("Sol_naive_Done_$(k)_$(N_d).jld2")
    global Done = D_Sol_naive_Done["Done"]
    global Sol_naive = D_Sol_naive_Done["Sol_naive"]
catch
    global Done = 0
end    

using DataFrames
using CSV
Cities = CSV.read("cities.csv")
global Data = Array{Float64,2}([Cities[:X]'; Cities[:Y]']);

include("src//ParaSelectACO.jl")
## Set the hyperparameters for ParaSelectACO
global Range = [0.0 5.0; 0.0 5.0; 0.0 1.0; 0.0 30.0]
global N_sample = 500;

if Done==0
    global Sol_naive = Int[]
end

println("Start from $(Done+1)")
using ProgressMeter
@showprogress 1 "Computing..." for i = Done+1:length(Path)
    ## println(i)
    P_i = Path[i]
    Dist_i = zeros(length(P_i), length(P_i))
    for j = 1:length(P_i)-1
        for k = j+1:length(P_i)
            Dist_i[j,k] = norm(Data[:,P_i][:,j]-Data[:,P_i][:,k])
            Dist_i[k,j] = Dist_i[j,k]
        end
    end
    Dist_i
    O = In_Out[i][1]
    G = In_Out[i][2];
    PSACO = ParaSelectACO(Range, N_sample, Dist_i, O, G; Na=200)
    if O==G
        append!(Sol_naive, P_i[PSACO["Best_Path"]][1:end-1])
    else
        append!(Sol_naive, P_i[PSACO["Best_Path"]])
    end
    global Done = i
    save("Sol_naive_Done_$(k)_$(N_d).jld2", Dict("Sol_naive"=>Sol_naive, "Done"=>Done))
end
#####################################################################
global Polar_Index = findfirst((x->(x==1)), Sol_naive)
global Z = [Sol_naive[Polar_Index:end]; Sol_naive[1:Polar_Index]].-1
###############################################################
## Save the final result as a csv file
global df = DataFrame([Z], [:Path]); ## store as dataframe type and add the column name :Path
CSV.write("Z_$(k)_$(N_d).csv", df)