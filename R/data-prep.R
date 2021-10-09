
library(dplyr)
library(rmapshaper)
library(sf)

dir_data = 'data'
fs_parks = file.path(dir_data, 'parks.rds')
fs_alcho = file.path(dir_data, 'alchohol.rds')


if(!file.exists(fs_parks)){
    parks = sf::st_read(file.path(dir_data, 'parks.geojson'))
    parks = rmapshaper::ms_simplify(parks,keep=0.2)
    saveRDS(parks, fs_parks)
}
if(!file.exists(fs_alcho)){
    alcho = sf::st_read(file.path(dir_data, 'alchohol.geojson'))
    alcho = rmapshaper::ms_simplify(alcho,keep=0.2)
    saveRDS(alcho, fs_alcho)
}


cat(as.character(Sys.time()),' - loading alcho zones\n')
alcho = readRDS(fs_alcho)
cat(as.character(Sys.time()),' - loading parks\n')
parks = readRDS(fs_parks)
parks = parks %>% dplyr::filter(ParkExtentSHAPE_Area < quantile(parks$ParkExtentSHAPE_Area,c(0.999)))
