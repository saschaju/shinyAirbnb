
library(shiny)
library(leaflet)
library(dplyr)
library(RColorBrewer)
library(rsconnect)


options(shiny.sanitize.errors = F)
# setwd("~/Google Drive/coursera/9_Data_Product_Development/Week_4/ShinyApp")
dat <- read.delim("airbnb_ch_2017-01-28.txt", sep = "|", stringsAsFactors = F)

dat[dat$room_type == "Ganze Unterkunft",]$room_type <- "Entire home"
dat[dat$room_type == "Privatzimmer",]$room_type <- "Private Room"
dat[dat$room_type == "Gemeinsames Zimmer",]$room_type <- "Shared Room"

dat$ppp <- dat$price / dat$person_capacity
dat <- subset(dat, ppp < 200)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Airbnb Listings in Switzerland"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("myroomtype", "Room Type",
                         unique(dat$room_type), unique(dat$room_type), inline = F),
      sliderInput(inputId = "mycapacity", label = "Capacity", min = 1, max = max(dat$person_capacity),
                  value = c(1, 3), step = 1, ticks = T, animate = T, post = " Person(s)"),
      sliderInput(inputId = "myreviews", label = "Nr. of Reviews", min = 1, max = max(dat$reviews_count),
                  value = c(0, 100), step = 1, ticks = T, animate = T, post = " Reviews"),
      sliderInput(inputId = "myprice", label = "Price per Person and Night", min = 0, max = max(dat$ppp),
                  value = c(0, 100), step = 10, ticks = T, animate = T, pre = "CHF ")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Summary", includeMarkdown("include.md")),
                  tabPanel("Airbnb", leafletOutput("leafletPlot"))
    )
  )
)))
