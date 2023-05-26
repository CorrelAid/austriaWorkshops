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
  
eez_fish_all_df %>% 
  ggplot() + 
  geom_raster(aes(x = Lon, 
                  y = Lat,
                  fill = fishing_hours)) +
  geom_sf(data = ne_countries(returnclass = 'sf', scale = 'medium')) +
  coord_sf(xlim = c(min(eez_fish_all_df$Lon), max(eez_fish_all_df$Lon)),
           ylim = c(min(eez_fish_all_df$Lat), max(eez_fish_all_df$Lat))) 
  