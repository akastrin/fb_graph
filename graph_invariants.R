setwd("~/Desktop/fb_graph")
require(package=igraph, quietly=TRUE)
source(file="my_functions.R")
source(file="power_law.R")
args <- commandArgs(trailingOnly=TRUE)
data.dir <- args[1]
limit <- as.integer(args[2])

all.files <- dir(path=data.dir)
my.files <- FilterGraphs(file.list=all.files, limit=limit)$files

if (is.null(my.files)) stop("Try again with different limit value.")
# Apply ComputeAll() function to each element in my.files
message("Start processing. Please wait...")
lol <- lapply(X=my.files, FUN=ComputeAll)
# Reshape list of lists to data.frame
out <- as.data.frame(do.call(rbind, lapply(X=lol, FUN=c, recursive=TRUE)),
		     row.names=my.files)
write.csv(x=out, file="graph_invariants.csv")
