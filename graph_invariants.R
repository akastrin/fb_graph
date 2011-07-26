setwd("~/Desktop/fb_graph/data_07-25-2011")

require(igraph)

file.name <- c("test2.net")
awk.str <- "awk \'{if(NR==1)sub(/^\xef\xbb\xbf/, \"\"); print}\'"
awk.str <- paste(awk.str, file.name)

pipe.con <- pipe(awk.str, encoding="UTF-8")
my.graph <- read.graph(file=pipe.con, format="pajek")

summary(my.graph)
