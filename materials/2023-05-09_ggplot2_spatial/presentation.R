#| echo: true
#| output-location: fragment
#| code-line-numbers: "|1,2,3|4|5|"

# read data from github
url <- 
  "https://raw.githubusercontent.com/CorrelAid/austriaWorkshops/main/materials/2022-09-27%20ggplot2_spatial/data/unemployment_austria.csv"
data <- read.csv(url, header = TRUE, sep = ";", dec = ",")
names(data)


#| echo: true
#| output-location: fragment
#| code-line-numbers: "|1,2|4,5|"

# rename variables
names(data) <- c("states", "unemployed", "unemployed.men", "unemployed.women", "rate", "rate.men", "rate.women")

# view data 
head(data)


#| echo: true
#| output-location: column-fragment
#| code-line-numbers: "|1,2|4,5,6,7|"

# order states by unemployment rates
data <- data[order(data$rate), ]   

# plot
library(ggplot2)
data$states <- factor(data$states, 
                      levels = data$states)
ggplot(data = data, aes(x = states, y = rate)) +
  geom_col()


#| echo: true
#| output-location: column
#| code-line-numbers: "|1,2,3|4|5,6,7|8,9,10,11,12,13,14,15,16|17,18,19,20,21|"

# plot
ggplot(data = data, aes(x = states, y = rate, 
                        fill = rate)) +
  geom_bar(stat = "identity") + 
  labs(title = "Unemployment Rates, AT",
       caption = "Source: STATISTICS AUSTRIA,
       Labour Force Survey (Microcensus) 2021.") +
  theme_bw() + 
  theme(
    axis.text.x = element_text(angle = 30,
                               vjust = 1,
                               hjust = 1),
    axis.title = element_text(face = "bold"),
    plot.title.position = "plot",
    legend.position = "top"
  ) +
  guides(
   fill = guide_colorsteps(title.position = 'top', 
                            even.steps = TRUE,
                            barwidth = 20, 
                            barheight = 0.5,
                            title.hjust = .5)) 


#| echo: true
#| output-location: fragment
#| code-line-numbers: "|1|2|4,5|7,8,9|1-11|"

library(sf)
library(rnaturalearth)

# read sf data for Austrian map
austria <- ne_states(country = "Austria", returnclass = "sf")

# look at the data
class(austria)

# glimpse at the map data
# austria


#| echo: true
#| output-location: fragment

# draw the map
ggplot(data = austria) +
  geom_sf()


#| echo: true
#| output-location: fragment
#| code-line-numbers: "|1,2|1,3|1,4|"

# merge 
data <- subset(data, states != "Austria")
names(data)[1] <- "name_en"
austria <- merge(austria, data, by = "name_en")


#| echo: true
#| output-location: column
#| code-line-numbers: "|1,2|3|4|5|6-11|12|13-16|17-22|23|"

# plot
library(colorspace)
p <- ggplot(data = austria) +
  theme_bw() +
  geom_sf(aes(fill = rate)) + 
  labs(
    title = "Unemployment rates Austria",
    caption = "Source: STATISTICS AUSTRIA,
       Labour Force Survey (Microcensus) 2021.",
    fill = "unemployment rate"
  ) +
  scale_fill_binned_sequential(palette = "Red-Blue") +
  theme(
    plot.title.position = "plot",
    legend.position = "bottom"
  ) +
  guides(
   fill = guide_colorsteps(title.position = 'bottom', 
                            even.steps = TRUE,
                            barwidth = 20, 
                            barheight = 0.5,
                            title.hjust = .5)) 
p


#| echo: true
#| output-location: column-fragment
#| code-line-numbers: "|1-2|4-6|8-11|12-15|16|"

library(maps)
library(ggrepel)

# read city names 
austria.cities <- subset(world.cities, 
  country.etc == "Austria" & pop > 40000)

# add to plot
p <- p + 
  geom_point(data = austria.cities, 
             aes(x = long, y = lat)) +
  geom_text_repel(data = austria.cities, 
                  aes(x = long, y = lat, 
                      label = name), 
                  size = 4) 
p

