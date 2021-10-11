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
# library("shinyjs")
library("osrm")
library("nngeo")
# library("mapview")
library("waiter")

source('R/func-helpers.R')
source('R/data-prep.R')

source('R/obj-clicked_points.R')
source('R/obj-routing.R')

options(shiny.autoload.r=FALSE)



lmap = leaflet::leaflet() %>%
    leaflet::addProviderTiles(provider = leaflet::providers$CartoDB.Positron, options = providerTileOptions(minZoom = 7)) %>%
    #https://stackoverflow.com/questions/44953146/r-leaflet-custom-attribution-string
    addTiles(urlTemplate = "",
             attribution = 'Routing via <a href="http://project-osrm.org/">OSRM</a> under the <a href="http://opendatacommons.org/licenses/odbl/">ODbL</a>.'
    ) %>%
    leaflet::setView(174.757,-36.847,zoom = 11) %>%
    # https://stackoverflow.com/questions/54667968/controlling-the-z-index-of-a-leaflet-heatmap-in-r/54676391
    addMapPane("parks", zIndex = 430) %>%
    addMapPane("alcho", zIndex = 440) %>%
    addMapPane("intersection", zIndex = 420) %>%
    addLayersControl(
        overlayGroups = c(as.character(1:5)),
        options = layersControlOptions(
            collapsed = F
        )
    ) %>%    removeLayersControl()

for (i in 1:5){

    lmap = lmap %>%
        leaflet::addPolygons(
            data = parks %>% dplyr::filter(GROUPING == i),
            stroke=FALSE,
            fillColor = "#5fd5a7",
            fillOpacity  = 0.8,
            popup = ~SAPPARK_DATADESCRIPTION,
            options = pathOptions(pane = "parks"),
            group = as.character(i)
        )
}









