library("shiny")
library("sf")
library("geojsonio")
library("dplyr")
library("leaflet")
library("rmapshaper")
library("magrittr")
library("devtools")

dir_data = 'data'
fs_parks = file.path(dir_data, 'parks.rds')


if(!file.exists(fs_parks)){
    parks = sf::st_read(file.path(dir_data, 'parks.geojson'))
    saveRDS(parks, fs_parks)
}



parks = readRDS(fs_parks)
