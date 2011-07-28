setwd("~/Desktop/fb_graph")
require(igraph)

data.dir <- "data_07-25-2011"
my.files <- dir(path=data.dir)

# Read Pajek file to graph object
GetGraph <- function(file) {
  awk.str <- "awk \'{if(NR==1)sub(/^\xef\xbb\xbf/, \"\"); print}\'"
  file.nobom  <- paste(awk.str, " ", "./", data.dir, "/", file, sep="")
  pipe.con <- pipe(description=file.nobom, encoding="UTF-8")
  my.graph <- read.graph(file=pipe.con, format="pajek")
  return(my.graph)
}

# Compute diameter (wrapper only)
GetDiameter <- function(graph) {
  graph.diam <- diameter(graph=graph, directed=FALSE)
  return(graph.diam)
}

# Compute size of giant component
GetGiantCompSize <- function(graph) {
  graph.size <- vcount(graph=graph)
  cl <- clusters(graph=graph)
  subgraph <- subgraph(graph=graph,
                       v=which(cl$membership == which.max(cl$csize) - 1) - 1)
  subgraph.size <- vcount(graph=subgraph)
  return(subgraph.size)
}

# Wrapper for functions above
ComputeAll  <- function(file) {
  graph <- GetGraph(file=file)
  diam <- GetDiameter(graph=graph)
  giant.size <- GetGiantCompSize(graph=graph)
  return(c(diam, giant.size))
}
  	
# Apply ComputeAll() function to each element in my.files
test1 <- lapply(X=my.files, FUN=ComputeAll)
# Reshape list to data.frame
test2 <- as.data.frame(x=do.call(what=rbind, args=bla))
