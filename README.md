# -Kaggle-Traveling-Santa-2018---Prime-Paths
This repository includes the codes I wrote for the titled competition on Kaggle. 
>Link to competition: https://www.kaggle.com/c/traveling-santa-2018-prime-paths <br>

The core of the approach is **ACO (Ant Colony Optimization)**. 
> For details, we refer the readers to https://ieeexplore.ieee.org/document/4129846 <br>

Notice that ACO was originally designed to solve TSP (Travelling Salesman Problem), where it is required to start and end on the same city. However, it is easy to implement the idea of ACO and generalize the algorithm to allow the starting and ending city to be different. This is the case for the ACO algorithm I wrote for this competition. 

## Main issues of implementing ACO directly on the collection of all cities are:
1. The size of the collection of cities is too big to be all processed at the same time. 
2. The hyper-paramters of ACO needs to be tuned.

To solve issue 1, k-means clustering is applied layer by layer. More precisely, suppose k = 20 is chosen, <br>
(1) partition the whole collection of cities into k sub-clusters; <br>
(2) for each sub-cluster $S$, if $\text{size}(S)\geq k$, sub-partition $S$ into $\text{roundup}(\text{size}(S)/k)$ sub-clusters; <br>
(3) continue (2) until all subclusters have size less than or equal to $k$.<br>
Notice that there is a tree structure in the process of establishing the sub-clusters, where the root represents the collection of all cities and for each node, its children are its sub-clusters. 

To solve issue 2, a naive randomized paramter selection is implemented. Namely, pre-setting a (bounded) range for the hyper-parameters $(\alpha, \beta, \rho, Q)$, then uniformly generate choices of the hyper-parameters inside the range. For each generated hyper-paramters, implement ACO and compare the results to obtain the best result. (**Remark**: At the beginning, **BFO (Bacterial Foraging Optimization)** is planned to be used for paramter tuning. However, I realized that it is not as efficient as expected, so I decided to give up on BFO and naively implement randomized selection.)

## Algorithm (High-Level):
1. Partition the collection of all cities into the tree structure mentioned in 1 above. 
2. For each sub-cluster that has sub-clusters, apply ACO, where the distances between sub-clusters are defined as the minimum among the distances between all possible pairs of inter-sub-cluster points. (The computational cost of this distance by brute force is very high. A random walk algorithm on two given point clouds is designed and implemented.)
3. With the results obtained in 2, it remains to apply ACO on "bottom sub-clusters". 

The resulting path is a "good" path. However, it is still "not good enough" to be competitive in this competition since the "prime city constraint" is not taken into consideration yet. To put the "prime city constraint" into effect, the following "path modifictaion" approach is invented and called **ACC (Ant Colony Correction)**:

Set a positive integer $k$, say $k = 20$.

4. For a given path $P$ of length $L$, randomly choose an integer $s$ in $[0,L-k]$. Consider the sub-path $P|{[s,s+k]}$. Now apply ACO on $P|{[s,s+k]}$ (several times); if the best sub-path obtained by ACO is better than $P|{[s,s+k]}$, replace $P|{[s,s+k]}$ by the obtained best path. 
5. Continue 4 as many times as desired. We may also change $k$ before continuing 4. 

## Issue encountered when implenting 5:
At the beginning, the improvement is very substantial; however, after 2 days, there are only very small improvements. My solution is to write parallel agents that modify the path simultaneously. However, it seems the improvement decrease is exponential and not able to be overcome by adding finitely many parallel agents.

## Final result/Comments:
My best result: 1531162.85 <br>
Rank-#1 result: 1513747.36 <br>
It seems my best result is not too far from the result ranked #1; however, the competition is so competitive(?) that the ranking difference is a bit high. I am also suspecting that there are teams sharing codes/results privately to make the ranking difference exaggerated. I list below the teams which have exactly the same results (I suppose this would happen with probability almost 0(?); namely, they share privately codes/results with probability almost 1(?)): 
>961 - 963, 912 - 920, 803 - 815, 790 - 794, 779 - 783, 759 - 766, 741 - 748, 728 - 729, 720 - 727, 718 - 719, 665 - 676, 646 - 648, 632 - 635, 628 - 631, 614 - 616, 600 - 604, 558 - 599, 556 - 557, 547 - 549, 540 - 542, 450 - 537, 447 - 448, 442 - 444, 439 - 441, 418 - 432, 415 - 416, 371 - 407, 339 - 370, 336 - 337, 303 - 313, 300 - 302, 282 - 285, 280 - 281, 277 - 279, 271 - 273, 252 - 253, 97 - 98.

If one doesn't believe in me, one can visit the following link to have a look:
> https://www.kaggle.com/c/traveling-santa-2018-prime-paths/leaderboard
