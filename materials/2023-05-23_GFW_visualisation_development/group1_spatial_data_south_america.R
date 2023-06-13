### r file group 1 - spatial visualization of south america


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


# # install natural earth package (ne) + ne data to plot real world polygons
# install.packages("rnaturalearth")
# install.packages("rnaturalearthdata")


# load packages
library(gfwr)
library(shiny)
library(shinyWidgets)
library(sf)
library(tidyverse)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)

### get the GFW API Token: 
# https://globalfishingwatch.org/our-apis/tokens

### save it in your environment and request it

key <- Sys.getenv("GFW_TOKEN")



# get data for a region

code_eez <- get_region_id(region_name = 'CHL', region_source = 'eez', key = key)

eez_fish_df <- get_raster(spatial_resolution = 'low',
                          temporal_resolution = 'yearly',
                          group_by = 'flag',
                          date_range = '2022-01-01,2022-06-01',
                          region = code_eez$id[1],
                          region_source = 'eez')


### group by flag state and create a bar plot

eez_fish_df %>% 
  filter(flag != "CHL") %>% 
  group_by(flag) %>% 
  summarize(fishing_hours = sum(`Apparent Fishing hours`, na.rm = T)) %>% 
  ggplot() +
  geom_col(aes(x = flag, y = fishing_hours)) 


## Ukraine fishes in Chilean waters?!


## we summarize each fishing activity by grid cell (Lat + Lon) to include fishing
# by all flag states

eez_fish_all_df <- eez_fish_df %>% 
  group_by(Lat, Lon) %>% 
  summarize(fishing_hours = sum(`Apparent Fishing hours`, na.rm = T)) 




## now we plot this
q <- quantile(eez_fish_all_df$fishing_hours)
eez_fish_all_df$fishing_hours_cat <- ifelse(eez_fish_all_df$fishing_hours <= q[1], 1,
                                            ifelse(eez_fish_all_df$fishing_hours <= q[2], 2, 
                                                   ifelse(eez_fish_all_df$fishing_hours <= q[3], 3,
                                                          ifelse(eez_fish_all_df$fishing_hours <= q[4], 4,
                                                                 ifelse(eez_fish_all_df$fishing_hours <= q[5], 5, 6
                                                                 )))))

eez_fish_all_df$fishing_hours_cat <- as.factor(eez_fish_all_df$fishing_hours_cat)                                                   
levels(eez_fish_all_df$fishing_hours_cat) <- c("very low", "low", "mid", "high", "very high" )

eez_fish_all_df %>% 
  ggplot() + 
  geom_raster(aes(x = Lon, 
                  y = Lat,
                  fill = fishing_hours_cat)) +
  geom_sf(data = ne_countries(returnclass = 'sf', scale = 'medium')) +
  coord_sf(xlim = c(min(eez_fish_all_df$Lon)-25, max(eez_fish_all_df$Lon)+15),
           ylim = c(min(eez_fish_all_df$Lat), max(eez_fish_all_df$Lat))) +
  scale_fill_viridis_d() +
  theme_light() +
  labs(x="",
       y="",
       fill="Fishing") +
  theme(legend.position = c(0.13, 0.17))


eez_fish_guafo_df <- eez_fish_all_df %>% filter(between(Lat,-44.2,-43),
                                                between(Lon,-75.9,-74.5))

library(ggforce)
(g1 <-eez_fish_all_df %>% 
    ggplot() + 
    geom_raster(aes(x = Lon, 
                    y = Lat,
                    fill = fishing_hours_cat)) +
    geom_sf(data = ne_countries(returnclass = 'sf', scale = 'medium')) +
    coord_sf(xlim = c(min(eez_fish_all_df$Lon)-25, max(eez_fish_all_df$Lon)+15),
             ylim = c(min(eez_fish_all_df$Lat), max(eez_fish_all_df$Lat))) +
    scale_fill_viridis_d() +
    geom_circle(aes(x0 = -75, y0 = -43, r = 2),
                inherit.aes = FALSE) +
    theme_light() +
    labs(x="",
         y="",
         fill="Fishing Hours") +
    theme(legend.position = c(0.13, 0.2))
)

(g2 <- eez_fish_guafo_df %>% 
    ggplot() + 
    geom_raster(aes(x = Lon, 
                    y = Lat,
                    fill = fishing_hours_cat)) +
    geom_sf(data = ne_countries(returnclass = 'sf', scale = 'medium')) +
    coord_sf(xlim = c(min(eez_fish_guafo_df$Lon), max(eez_fish_guafo_df$Lon+0.12)),
             ylim = c(min(eez_fish_guafo_df$Lat), max(eez_fish_guafo_df$Lat))) +
    scale_fill_viridis_d() +
    labs(x="",
         y="") +
    theme(legend.position = "none",
          axis.text.x=element_blank(), #remove x axis labels
          axis.ticks.x=element_blank(), #remove x axis ticks
          axis.text.y=element_blank(),  #remove y axis labels
          axis.ticks.y=element_blank()  #remove y axis ticks
    )
)


library(patchwork)
g1 + ggtitle('Fishing Hours of the Coast of Chile') +
  inset_element(g2, 0.0, 0.4, 0.35, 0.95) + ggtitle('Guafo Island')
