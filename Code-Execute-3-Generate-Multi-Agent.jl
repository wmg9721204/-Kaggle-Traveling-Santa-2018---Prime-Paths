## Open and read the model code
f = open("Code-Execute-5-ACC-Good-Path-newest-1.jl")
global R = readlines(f);
close(f)

## Set the length of sub-paths to be modified
global k = 50
global N = 20 ## number of agents

## Generate the codes
using DelimitedFiles
for n_P = 1:N
    filename = "Code-Execute-5-ACC-Good-Path-newest-$(n_P).jl"
    writedlm(filename, 0)
    open(filename, "w") do g
        for i = 1:length(R)
            if i==15
                line = "global k = $k"
                write(g, line*"\n")  
            elseif i==65
                line = "    writedlm(Path_File*\"_Progress_$(n_P)_\$(i)_of_\$(N_c).txt\",0)"
                write(g, line*"\n")
            elseif i==67
                line = "        rm(Path_File*\"_Progress_$(n_P)_\$(i-1)_of_\$(N_c).txt\")"
                write(g, line*"\n")
            elseif i==75
                line = "        writedlm(\"Temp//Path_$(n_P).txt\", [[\"Start\", a, \"Improved_Length\", Improve, \"Path\"]; GoodPath[a:b][Path_a]])"
                write(g, line*"\n")
            else
                line = R[i]
                write(g, line*"\n")
            end
        end
    end
end