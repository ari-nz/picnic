library("pkgload")
library("smoothr")
library("devtools")
library("dplyr")
library("geojsonio")
library("leaflet")
library("magrittr")
library("rmapshaper")
library("sf")
library("shiny")
library("shinythemes")

source('R/func-helpers.R')
source('R/data-prep.R')

source('R/obj-clicked_points.R')
points = Points$new()




lmap = leaflet::leaflet(data = parks) %>%
    leaflet::addProviderTiles(provider = leaflet::providers$CartoDB.Positron) %>%
    leaflet::setView(174.757,-36.847,zoom = 10)# %>%
    #leaflet::addPolygons(stroke=FALSE, fillColor = "#5fd5a7", fillOpacity  = 1)# %>%
    # leaflet::addPolygons(stroke=FALSE, fillColor = "#FFA500", fillOpacity  = 0.7, data = alcho)








