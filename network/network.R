### COrrelAidX Austria 
### Network visualization
### Arne Langlet, 04.10.2022

# clean environment
gc()
rm(list = ls())


# set working directory
setwd("C:/Users/Felix/Documents/# CorrelAid/austriaWorkshops/network")

# load packages
library(dplyr)
library(tidyverse)
library(readxl)
library(data.table)
library(zoo)
library(lubridate)
library(openxlsx)
library(stringr)
library(readr)
library(tidytext)
library(igraph)
library(kableExtra)
library(tm)
library(ggthemes)
library(magrittr)
library(igraph)
library(rtweet)

# read data
hashtag_result <- read.csv("twitter_data.csv")



head(hashtag_result)

# some cleaning

## all to lower 
hashtag_result$tweet <- str_to_lower(hashtag_result$tweet)
hashtag_result$username <- str_to_lower(hashtag_result$username)

## delete NAs & duplicates
hashtag_result <- filter(hashtag_result, !is.na(username))
hashtag_result <- hashtag_result %>% distinct(created_at, tweet, author.id, .keep_all = TRUE)


# build network:
##create edgelist of authors and links that the tweets referred to with "@" as in references or retweets

links <- str_extract_all(hashtag_result$tweet, "@\\w*\\b")
links <- sapply(links, function(s) paste(s, collapse=';'))
links <- gsub("[@]", "", links)
df <- data.frame(cbind( hashtag_result$username, links))

edgelist <- separate_rows(df, links, convert = TRUE)

## delete tweets without references 
edgelist <- filter(edgelist, links != "")


## create weights 
edgelist_w <- as.data.frame(table(edgelist))
edgelist_w <- filter(edgelist_w, Freq > 0)

## name variables and set class
colnames(edgelist_w) <- c("Source", "Target", "Weight")
edgelist_w$Source <- as.character(edgelist_w$Source)
edgelist_w$Target <- as.character(edgelist_w$Target)
edgelist_w$Weight <- as.numeric(edgelist_w$Weight)


## subset no self-reference (loops)
edgelist_w <- subset(edgelist_w, !ifelse(edgelist_w$Source == edgelist_w$Target, TRUE, FALSE))


## write network matrix with weigths
write.csv(edgelist_w, "edgelist_weighted.csv", row.names = FALSE)

## create network from matrix / dataframe and keep weights as numeric...
net_matrix <- as.data.frame(edgelist_w)
net <- graph_from_data_frame(net_matrix, directed = TRUE)


# have a look at network
net


## communities
clp <- cluster_walktrap(net)

V(net)$community <- clp$membership
length(unique((clp$membership)))

rain <- rainbow(42, alpha=.5)
V(net)$color <- rain[V(net)$community]


## centrality
V(net)$degree <- degree(net, mode = "in")



plot(net,
     layout = layout_with_dh, 
     #vertex.size = V(net)$degree,
     vertex.label.cex = 1,
     #vertex.color = V(net)$color,
     edge.width = E(net)$Weight,
     edge.arrow.size = .5)


# now the interactive network
library(visNetwork)


## create node list

nodes <- data.frame(id = V(net)$name)


### add labels on nodes
nodes$label <- V(net)$name

### size adding value
nodes$size <- V(net)$degree          




# create edge table

el <- data.frame(get.edgelist(net))

edges <- data.frame(from = el$X1, to = el$X2,
                    
                    # add labels on edges                  
                    label = c("reference"),
                    
                    # arrows
                    arrows = c("to"),
                    
                    color = c("yellow"), 
                    width = E(net)$Weight)



# conditional attributes
edges$label <- ifelse(E(net)$Weight <= 3, "weak reference", "strong reference")


# add groups on nodes 

# nodes$id
 
 presse <- c("derstandardat", "orf", "hartaberfair", "diepressecom", "ndr", "gi_presse", "tachlesnews", "kleinezeitung", "morgenpost", "sfrnews")
 nodes$group <- ifelse(nodes$id %in% presse, 1, 0)
 #control shape of nodes
 nodes$shape <- ifelse(nodes$group == 1, "square", "dot")
 # do not use "circle" here because circle always has the label inside the shape
 # color by community 
 nodes$color <- V(net)$color
  





plot <- visNetwork(nodes, edges, height = "1000px", width = "100%") %>% 
  visNodes(font = list (size = 25)) %>% 
  visIgraphLayout(layout = "layout_with_dh") %>% 
  visPhysics(stabilization = FALSE) %>%
  visEdges(smooth = FALSE) 
 


visSave(plot, file = "plot.html")

