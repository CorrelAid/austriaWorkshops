## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# read data from github
url <- 
  "https://raw.githubusercontent.com/CorrelAid/austriaWorkshops/main/ggplot2_2/data/unemployment_austria.csv"
data <- read.csv(url, header = TRUE, sep = ";", dec = ",")
names(data)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# rename variables
names(data) <- c("states", "unemployed", "unemployed.men", "unemployed.women", "rate", "rate.men", "rate.women")

# view data 
head(data)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# order states by unemployment rates
data <- data[order(data$rate), ]   

# plot
library(ggplot2)
data$states <- factor(data$states, 
                      levels = data$states)
ggplot(data = data, aes(x = states, y = rate)) +
  geom_col()


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(sf)
library(rnaturalearth)

# read sf data for Austrian map
austria <- ne_states(country = "Austria", returnclass = "sf")

# look at the data
class(austria)
# austria


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# draw the map
ggplot(data = austria) +
  geom_sf()


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# merge 
data <- subset(data, states != "Austria")
names(data)[1] <- "name_en"
austria <- merge(austria, data, by = "name_en")


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

