
library(shiny)
library(leaflet)
library(dplyr)
library(RColorBrewer)
library(rsconnect)

Sys.setlocale("LC_CTYPE","de_DE")
options(shiny.sanitize.errors = F)
# setwd("~/Google Drive/coursera/9_Data_Product_Development/Week_4/ShinyApp")

shinyServer(function(input, output) {
  
  dat <- read.delim("airbnb_ch_2017-01-28.txt", sep = "|", stringsAsFactors = F)
  
  dat[dat$room_type == "Ganze Unterkunft",]$room_type <- "Entire home"
  dat[dat$room_type == "Privatzimmer",]$room_type <- "Private Room"
  dat[dat$room_type == "Gemeinsames Zimmer",]$room_type <- "Shared Room"
  
  dat$ppp <- dat$price / dat$person_capacity
  dat <- subset(dat, ppp < 200)
  
  pal <- colorNumeric(
    palette = rev(brewer.pal(5, "RdYlBu")),
    domain = dat$ppp)
    
  output$leafletPlot <- renderLeaflet({
    
      myroomtype <- input$myroomtype  
      mycapacity <- input$mycapacity
      myreviews <- input$myreviews
      myprice <- input$myprice
        
      dat1 <- dat %>% filter(room_type == myroomtype,
                             person_capacity >= mycapacity[1],
                             person_capacity <= mycapacity[2],
                             reviews_count >= myreviews[1],
                             reviews_count <= myreviews[2],
                             ppp >= myprice[1],
                             ppp <= myprice[2])
      leaflet(dat1) %>% 
      addProviderTiles("CartoDB.Positron") %>%
      addCircleMarkers(~lng, ~lat,
                       radius = 3,
                       color = ~pal(ppp),
                       stroke = FALSE,
                       fillOpacity = 1,
                       popup=~as.character(paste("<h3>", city, "</h3>",
                                                 "<br>Price per person and nigth: ", curr, round(ppp,0),
                                                 "<br>Total price per night:",curr, price,
                                                 "<br>Person Capacity:", person_capacity,
                                                 "<br>Beds:",beds,
                                                 "<br>Type:",room_type,
                                                 "<br>Listing ID:", id,
                                                 "<br>Host ID:",user_id,
                                                 "<br>Nr. of Reviews: ",reviews_count
                       ))) %>%
      addLegend("bottomright", pal = pal, values = ~ppp,
                title = "Price per Person and Night",
                labFormat = labelFormat(prefix = "CHF "),
                opacity = 1
      )
  })
  
})

