#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#

library(shiny)
require(tidyverse)
require(ggthemes)
require(shinythemes)
library(png)
library(shinyWidgets)
library(gfwr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)
library(leaflet)


## api access token to gfw database
key <- Sys.getenv("GFW_TOKEN")


## background color
default_background_color <- "#f5f5f2"


# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel('GFW Data Viz'),

  setBackgroundColor(default_background_color),
  
  sidebarLayout(
    sidebarPanel(
      tags$a(href="https://www.correlaid.org/correlaidx/austria/",
             tags$img(src='correlaid.png', height='120', width='150')),
      tags$a(href="https://globalfishingwatch.org/",
             tags$img(src='gfw.png', height='120', width='150'))),
     
      mainPanel(navbarPage(title = "",
                           tabPanel( "Map_leaflet", 
                                     leafletOutput(outputId = 'map1')),
                           tabPanel( "Map_sf", 
                                     plotOutput(outputId = 'map2'))
                                        ))
    
    
        
    )
  )

# Define server logic required to draw a histogram
server <- function(input, output) {

  output$map1 <- renderLeaflet({
    leaflet() %>%
      addTiles() 
  })
  output$map2 <- renderPlot({
    world <- ne_countries(scale = "medium", returnclass = "sf")
    ggplot(data = world) +
      geom_sf()
  })

  
 
}



# Run the application 
shinyApp(ui = ui, server = server)


