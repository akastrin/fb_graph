# Read Pajek file to igraph object
GetGraph <- function(file) {
  awk.str <- "awk \'{if(NR==1)sub(/^\xef\xbb\xbf/, \"\"); print}\'"
  file.nobom  <- paste(awk.str, " ", "./", data.dir, "/", file, sep="")
  pipe.con <- pipe(description=file.nobom, encoding="UTF-8")
  my.graph <- read.graph(file=pipe.con, format="pajek")
  return(my.graph)
}

# Compute diameter
GetDiameter <- function(graph) {
  graph.diam <- diameter(graph=graph, directed=FALSE)
  rval <- list(diam=graph.diam)
  return(rval)
}

# Compute size of giant component
GetGiantCompSize <- function(graph) {
  graph.size <- vcount(graph=graph)
  cl <- clusters(graph=graph)
  subgraph <- subgraph(graph=graph,
                       v=which(cl$membership == which.max(cl$csize) - 1) - 1)
  subgraph.size <- vcount(graph=subgraph)
  rval <- list(g.size=subgraph.size)
  return(rval)
}

# Count vertices
CountVertices <- function(file) {
  graph <- GetGraph(file=file)
  return(vcount(graph))
}

# Count edges
CountEdges <- function(file) {
  graph <- GetGraph(file=file)
  return(ecount(graph))
}

# Compute power distribution parameters
TestPowerLaw <- function(graph) {
  degree <- degree(graph) + 1
  fit <- FitPowerLaw(x=degree)
  rval <- list(d.stat=fit$statistic, p.val=fit$p.value, xmin=fit$xmin,
	       n=fit$n, alpha=fit$alpha)  
  return(rval)
}

# Select graphs according to number of edges
FilterGraphs <- function(file.list, limit) {
  edges <- sapply(X=file.list, FUN=CountEdges)
  if (limit >= min(edges)) {
    index <- which(edges <= limit)
    message(paste("Filtered", length(index), "out of", length(all.files),
		"graphs."))
    rval <- list(files=all.files[-index], ind=index)
    return(rval)
  }
}

# Wrapper for functions above
ComputeAll  <- function(file) {
  graph <- GetGraph(file=file)
  diam <- GetDiameter(graph=graph)
  g.size <- GetGiantCompSize(graph=graph)
  p.law <- TestPowerLaw(graph=graph)
  return(c(diam, g.size, p.law))
  progress_bar_text$step()
}
