# Install ggplot for visualizing
install.packages("ggplot2")

# install shiny apps
install.packages("shiny")

# install sf for spatial visualizations
install.packages("")

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
