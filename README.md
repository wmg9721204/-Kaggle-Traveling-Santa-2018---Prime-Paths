# -Kaggle-Traveling-Santa-2018---Prime-Paths
This repository includes the codes I wrote for the titled competition on Kaggle. Link to competition: https://www.kaggle.com/c/traveling-santa-2018-prime-paths <br>

The core of the approach is **ACO (Ant Colony Optimization)**. 
>For those interested, refer to https://ieeexplore.ieee.org/document/4129846 <br>

Main issue of implementing ACO directly:
1. The size of the collection of cities is too big to be all processed at the same time. 
2. The hyper-paramters of ACO needs to be tuned. 

To solve issue 1, k-means clustering is applied layer by layer. More precisely, suppose k = 20 is chosen, 
(1) partition the whole collection of cities into k sub-clusters; <br>
(2) for each sub-cluster S, if $$size(S)\geq k$$, sub-partition it into <br>

To solve issue 2, a naive randomized paramter selection is implemented. 

The core of the approach I took is called **ACO (Ant Colony Optimization)**, where the behavior of an ant colony is mimicked to obtain a 
"promisingly short" path going through all assinged points once and only once. Roughly speaking, several artificial ants construct/modify paths using the following algorithm:
1. The 1st ant takes a completely blind search (i.e. the probability of the choice from a point to next point is uniformly distributed) and leaves pheromones on its path with amount inverse proportaional to the total distance of its path.
2. With the updated pheromone, the 2nd ant has some biases on the choice from a point to another according to the amount of pheromone left by the 1st ant. Now a new path is constructed by the 2nd ant. Update the pheromone amount inversely proportional to the total distance of its path. 
3. Repeat step 2. for the 3rd, 4th, ..., ants. Eventually, the pheromone distribution "could converge" and the final path is obtained.
The main problem for ACO is that there are some hyper-parameters to tune: $$\alpha$$, $$\beta$$
