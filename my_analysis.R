require(igraph)
source("my_functions.R")
all.files <- dir(path="data_07-25-2011")

edge.dist <- sapply(X=all.files, FUN=CountEdges)
# Manually expect frequency distribution and choose appropriate limit value
table(edge.dist)

# From console: Rscript graph_invariants.R data_07-25-2011 3

# Read compiled graph_invariants.csv file
data <- read.csv(file="graph_invariants.csv", row.names=1)
