### r file group 1 - spatial visualization of south america


# Install ggplot for visualizing
install.packages("ggplot2")

# install shiny apps
install.packages("shiny")

# install sf for spatial visualizations
install.packages("sf")

# install Global Fishing Watch R package
devtools::install_github("GlobalFishingWatch/gfwr")


# load packages
library(gfwr)
library(shiny)
library(shinyWidgets)
library(sf)
library(tidyverse)
library(ggplot2)


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


