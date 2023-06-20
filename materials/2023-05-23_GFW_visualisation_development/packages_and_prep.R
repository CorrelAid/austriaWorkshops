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


### then we can get gfw data as following: 
# 
# get_vessel_info(query = 224224000, 
#                 search_type = "basic", 
#                 dataset = "all", 
#                 key = key)
# 
# 
# port_visits <- get_event(event_type='port_visit',
#           confidences = '4',
#           key = key, 
#           start_date = "2022-01-01",
#           end_date = "2022-01-02")



# get data for a region

code_eez <- get_region_id(region_name = 'CHL', region_source = 'eez', key = key)

eez_fish_df <- get_raster(spatial_resolution = 'low',
                          temporal_resolution = 'yearly',
                          group_by = 'flag',
                          date_range = '2022-01-01,2022-06-01',
                          region = code_eez$id[1],
                          region_source = 'eez')






# get data for network who fished where

## query gfw api 
usa_longline <- get_vessel_info(
  query = "flag = 'USA' AND geartype = 'set_longlines'", 
  search_type = "advanced", 
  dataset = "fishing_vessel",
  key = key
)


## paste all vessel ids together
usa_longline_ids <- paste0(usa_longline$id[1:length(usa_longline)], collapse = ',')


## get fishing activity
df_usa_longline_fishing <- get_event(event_type='fishing',
          vessel = usa_longline_ids,
          start_date = "2022-01-01",
          end_date = "2022-10-01",
          key = key
)


## get id of eezs in which these activities took place

fished_eezs <- c()

for(i in 1:62){
   id <- paste0(df_usa_longline_fishing$regions[[i]]$eez[1])
   fished_eezs <- data.frame(rbind(fished_eezs, id))}



## organize dataframe
fished_eezs$row <- row.names(fished_eezs)  
rownames(fished_eezs)<-NULL

# fished_eezs$rbind.fished_eezs..id. %>% as.numeric()
# 
# get_region_id(region_name = 8456,
#               key = key) 


## merge eez id with the name of the state  
df <- fished_eezs %>% select(rbind.fished_eezs..id.) %>% 
  dplyr::rowwise() %>%
  dplyr::mutate(eez_name = get_region_id(region_name = as.numeric(rbind.fished_eezs..id.),
                                         region_source = 'eez',
                                         key = key)$label)

