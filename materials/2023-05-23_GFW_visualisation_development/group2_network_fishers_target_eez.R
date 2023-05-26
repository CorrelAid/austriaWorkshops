### r file group 2 - network map between fishing states and eezs


# # Install ggplot for visualizing
# install.packages("ggplot2")
# 
# # install shiny apps
# install.packages("shiny")
# 
# # install sf for spatial visualizations
# install.packages("sf")
# 
# # install Global Fishing Watch R package
# devtools::install_github("GlobalFishingWatch/gfwr")
# 

# # install vs network for interactive network visualization
# install.packages("visNetwork")


# # install igraph for network graph handling
# install.packages("igraph")


# load packages
library(gfwr)
library(shiny)
library(shinyWidgets)
library(sf)
library(tidyverse)
library(ggplot2)
library(visNetwork)
library(igraph)


### get the GFW API Token: 
# https://globalfishingwatch.org/our-apis/tokens

### save it in your environment and request it

key <- Sys.getenv("GFW_TOKEN")


# get data for network who fished where

## query gfw api 
longline <- get_vessel_info(
#  query = "flag = 'USA' AND geartype = 'set_longlines'",
   query = "geartype = 'set_longlines'", 
  search_type = "advanced", 
  dataset = "fishing_vessel",
  key = key
)


# exactly 10000 obs by coincidence?


## paste all vessel ids together
longline_ids <- paste0(longline$id[1:100], collapse = ',')




## get fishing activity
df_longline_fishing <- get_event(event_type='fishing',
                                     vessel = longline_ids,
                                     start_date = "2022-01-01",
                                     end_date = "2022-02-01",
                                     key = key
)


## get id of eezs in which these activities took place

df_longline_fishing %>% filter(!is.na())


## filter out where no flag state information is available

df_longline_fishing <- df_longline_fishing %>%
  rowwise() %>%
  filter(!is.null(vessel$flag))




fished_eezs <- c()
for(i in 1:nrow(df_longline_fishing)){
  id <- paste0(df_longline_fishing$regions[[i]]$eez[1])
  flag <- paste0(df_longline_fishing$vessel[[i]]$flag[1])
  df <- cbind(flag, id)
  fished_eezs <- data.frame(rbind(fished_eezs, df))}



## organize dataframe
fished_eezs$row <- row.names(fished_eezs)  
rownames(fished_eezs)<-NULL
fished_eezs <- select(fished_eezs, -c("row"))

colnames(fished_eezs) <- c("flag", "fished_eez")


# fished_eezs$rbind.fished_eezs..id. %>% as.numeric()
# 
# get_region_id(region_name = 8456,
#               key = key) 


## merge eez id with the name of the flag state  
df <- fished_eezs %>% select(flag, fished_eez) %>% 
  dplyr::rowwise() %>%
  dplyr::mutate(eez_name = get_region_id(region_name = as.numeric(fished_eez),
                                         region_source = 'eez',
                                         key = key)$label)


get_region_id()

edgelist <- df %>% select(flag, eez_name)
  
  
  
  ## create weights 
edgelist_w <- as.data.frame(table(edgelist))
edgelist_w <- filter(edgelist_w, Freq > 0)

## name variables and set class
colnames(edgelist_w) <- c("Source", "Target", "Weight")
edgelist_w$Source <- as.character(edgelist_w$Source)
edgelist_w$Target <- as.character(edgelist_w$Target)
edgelist_w$Weight <- as.numeric(edgelist_w$Weight)


## subset no self-reference (loops)
# edgelist_w <- subset(edgelist_w, !ifelse(edgelist_w$Source == edgelist_w$Target, TRUE, FALSE))



## create network from matrix / dataframe and keep weights as numeric...
net_matrix <- as.data.frame(edgelist_w)
net <- graph_from_data_frame(net_matrix, directed = TRUE)



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
                    label = c("fishes in"),
                    
                    # arrows
                    arrows = c("to"),
                    
                    color = c("yellow"), 
                    width = E(net)$Weight)










plot <- visNetwork(nodes, edges, height = "1000px", width = "100%") %>% 
  visNodes(font = list (size = 25)) %>% 
  visIgraphLayout(layout = "layout_with_dh") %>% 
  visPhysics(stabilization = FALSE) %>%
  visEdges(smooth = FALSE) 

  
plot
