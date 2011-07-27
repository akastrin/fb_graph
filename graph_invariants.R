setwd("~/Desktop/fb_graph")

require(igraph)

data.dir <- "data_07-25-2011"
my.files <- dir(path=data.dir)

GetInvariate <- function(file.name) {
  awk.str <- "awk \'{if(NR==1)sub(/^\xef\xbb\xbf/, \"\"); print}\'"
  #   file.nobom <- paste(awk.str, file.name)
  file.nobom  <- paste(awk.str, " ", "./", data.dir, "/", file.name, sep="")
  pipe.con <- pipe(description=file.nobom, encoding="UTF-8")
  my.graph <- read.graph(file=pipe.con, format="pajek")
  my.diam <- diameter(graph=my.graph, directed=FALSE)
  return(my.diam)
}

bla <- sapply(X=my.files, FUN=GetInvariate)
