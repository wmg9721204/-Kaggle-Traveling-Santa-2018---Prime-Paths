"""
**NormalDensity** computes the pdf of a d-dimension normal distribution <br>
Inputs:
1. d::Int, the dimension of the pdf
2. mu::Array{Float64,1}, the mean of the pdf
3. Sigma=eye(2)::Array{Float64,2}, the covariance matrix of the pdf

Output:
the desired pdf function with d variables

"""
function NormalDensity(d::Int, mu::Array{Float64,1}, Sigma=eye(2)::Array{Float64,2})
    return (z-> 1/sqrt((2pi)^d*det(Sigma))*exp(1.0)^((-(1/2)*(z-mu)'*inv(Sigma)*(z-mu))[1]))
end

using StatsBase # "sample"
using Statistics # "cov"
using SpecialFunctions # "gamma"
using LinearAlgebra #"eigen"

"""
**f_KDE(X::Array{Float64,2}, N::Int, H = zeros(size(X,1), size(X,1))::Array{Float64,2})** is a function computing the KDE of a given point cloud.

**Inputs:**
1. a point cloud X in dimension d of size n, matrix dimension = d x n
2. N::Int, the size of subsample for computing KDE
3. H=H_MS::Array{Floa64,2}, the bandwidth parameter

**Output:**
a function: R^d→R

**Details:** use Gaussian kernel and H_max bandwidth as default
"""
function f_KDE(X::Array{Float64,2}, N::Int, 
        H = zeros(size(X,1), size(X,1))::Array{Float64,2})
    
    d = size(X,1) ## dimension of the data
    R_K = 1/((2*sqrt(pi))^d) ## the R(K), the integral of the squared pdf, where K is the "normal" kernel
    n = size(X,2)
    
    Rand_N = Int[]
    if N<n
        Rand_N = sample(collect(1:n), N, replace = false)
    elseif N>n
        error("The subsample size is greater than the original sample size!!!")
    else
        Rand_N = collect(1:N)
    end
    Rand_N
    if H==zeros(d,d)
        S = cov(X') ## Sample covariance    
        ## The H used in maximal smoothness
        H_MS = (((d+8)^((d+6)/2)*pi^(d/2)*R_K)/(16(d+2)gamma(d/2+4)))^(2/(d+4))*n^(-2/(d+4))*S
        H = H_MS
    else
        E = eigen(H)
        if sum((E.values).>0)<d
            error("The bandwidth H is NOT positive definit!!!")
        end
    end
        
    
    ## Kernels = [NormalDensity(Data[i,:], H_MS) for i=1:N]
    f_H(z) = 1/N*sum([NormalDensity(d, X[:,i], H)(z) for i=1:N])
    return f_H
end

println("Functions 'NormalDensity', 'f_KDE' imported")