function Old_Length(a::Int, k::Int, D::Array{Float64,2}, GoodPath::Array{Int, 1})
    b = a+k-1
    L_o = 0.0 ## total length of the old path
    for j = a:b-1
        if ((j%10)==1)&&(j!=1) ## i.e. step 11, 21, 31, 41, etc.
            if isprime(GoodPath[a:b][j-a+1]+1)
                L_o = L_o + D[j-a+1, j-a+2]
            else
                L_o = L_o +1.1*D[j-a+1, j-a+2]
            end
        else
            L_o = L_o + D[j-a+1, j-a+2]
        end
    end
    L_o
end

function New_Length(a::Int, k::Int, D::Array{Float64,2}, GoodPath::Array{Int, 1}, Path_a::Array{Int, 1})
    b = a+k-1
    L_n = 0.0 ## total length of the new path
    for j = a:b-1
        if ((j%10)==1)&&(j!=1) ## i.e. step 11, 21, 31, 41, etc.
            if isprime(GoodPath[a:b][Path_a][j-a+1]+1)
                L_n = L_n + D[Path_a[j-a+1], Path_a[j-a+2]]
            else
                L_n = L_n +1.1*D[Path_a[j-a+1], Path_a[j-a+2]]
            end
        else
            L_n = L_n + D[Path_a[j-a+1], Path_a[j-a+2]]
        end
    end
    L_n
end