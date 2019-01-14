# -Kaggle-Traveling-Santa-2018---Prime-Paths
This repository includes the codes I wrote for the titled competition on Kaggle. Link to competition: https://www.kaggle.com/c/traveling-santa-2018-prime-paths <br>

The core of the approach is **ACO (Ant Colony Optimization)**. 
> For details, we refer the readers to https://ieeexplore.ieee.org/document/4129846 <br>

Main issue of implementing ACO directly:
1. The size of the collection of cities is too big to be all processed at the same time. 
2. The hyper-paramters of ACO needs to be tuned. 

To solve issue 1, k-means clustering is applied layer by layer. More precisely, suppose k = 20 is chosen, <br>
(1) partition the whole collection of cities into k sub-clusters; <br>
(2) for each sub-cluster $S$, if $\text{size}(S)\geq k$, sub-partition $S$ into $\text{roundup}(\text{size}(S)/k)$ sub-clusters; <br>
(3) continue (2) until all subclusters have size less than or equal to $k$.<br>
Notice that there is a tree structure in the process of establishing the sub-clusters, where the root represents the collection of all cities and for each node, its children are its sub-clusters. 

To solve issue 2, a naive randomized paramter selection is implemented. Namely, pre-setting a range for the hyper-parameters $(\alpha, \beta, \rho, Q)$, then uniformly generate choices of the hyper-parameters inside the range. For each generated hyper-paramters, implement ACO and compare the results to obtain the best result. (**Remark**: At the beginning, BFO (Bacterial Foraging Optimization) is planned to be used for paramter tuning. However, I realized that it is not as efficient as expected, so I just gave up on BFO and naively implements randomized selection.)
