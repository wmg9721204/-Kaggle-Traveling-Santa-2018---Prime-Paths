# -Kaggle-Traveling-Santa-2018---Prime-Paths
This repository includes the codes I wrote for the titled competition on Kaggle. Link to competition: https://www.kaggle.com/c/traveling-santa-2018-prime-paths <br>
The core of the approach I took is called **ACO (Ant Colony Optimization)**, where the behavior of an ant colony is mimicked to obtain a 
"promisingly short" path going through all assinged points once and only once. Roughly speaking, several artificial ants obeys the following algorithm:
1. The 1st ant takes a completely blind search (i.e. the probability of the choice from a point to next point is uniformly distributed) and leaves pheromones on its path with amount inverse proportaional to the total distance of its path.
2. With the updated pheromone, the 2nd ant has some biases on the choice from a point to another according to the amount of pheromone left by the 1st ant. Now a new path is constructed by the 2nd ant. Update the pheromone amount inversely proportional to the total distance of its path. 
3. Repeat step 2. for the 3rd, 4th, ..., ants. Eventually, the pheromone distribution converges and the final path is obtained.
