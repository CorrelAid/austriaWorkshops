devtools::install_github("GlobalFishingWatch/gfwr")


library(gfwr)

key <- Sys.getenv("GFW_TOKEN")


get_vessel_info(query = 224224000, 
                search_type = "basic", 
                dataset = "all", 
                key = key)


port_visits <- get_event(event_type='port_visit',
          confidences = '4',
          key = key, 
          start_date = "2022-01-01",
          end_date = "2022-01-02"
          

                   
          
)
