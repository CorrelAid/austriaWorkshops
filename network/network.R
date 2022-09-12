
### vis network

library(visNetwork)





nodes <- data.frame(id = V(net)$name)


# add labels on nodes
nodes$label <- ifelse(nodes$id %in% ha, "High Ambition\nCoalition",
                      ifelse((nodes$id %in% temp_conflict$actor & ! (nodes$id %in% ha)), "Other States", V(net)$label))


# add groups on nodes 
nodes$group <- ifelse(nodes$id %in% temp_conflict$actor, 1, 0)

# size adding value
#value = degree(net),          

# control shape of nodes
nodes$shape <- ifelse(nodes$group == 1, "circle", "square")

# color
nodes$color <- ifelse(V(net)$type == 1, "darkgrey", "lightgrey")





el <- data.frame(get.edgelist(net))
el$pro <- E(net)$pro




edges <- data.frame(from = el$X1, to = el$X2,
                    
                    # add labels on edges                  
                    label = ifelse(el$pro== 1, "opposition",
                                   ifelse(el$pro == 2, "flexible",
                                          ifelse(el$pro == 3, "support", "grey"))),
                    
                    # arrows
                    arrows = c("to"),
                    
                    color = ifelse(edges$label== "opposition", "red",
                                   ifelse(edges$label == "flexible", "yellow",
                                          ifelse(edges$label== "support", "green", "grey"))))











plot <- visNetwork(nodes, edges, height = "1000px", width = "100%") %>% 
  visNodes(font = list (size = 25)) %>% 
  visIgraphLayout(layout = "layout_with_dh") %>% 
  visPhysics(stabilization = FALSE) %>%
  visEdges(smooth = FALSE) %>%
  visIgraphLayout()

plot

visSave(plot, file = "figure1_with high ambition.html")