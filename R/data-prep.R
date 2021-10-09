
library(dplyr)
library(rmapshaper)
library(sf)

dir_data = 'data'
fs_parks = file.path(dir_data, 'parks.rds')
fs_alcho = file.path(dir_data, 'alchohol.rds')

sf_use_s2(TRUE)
if(!file.exists(fs_parks)){
    parks = sf::st_read(file.path(dir_data, 'parks.geojson'))
    parks = parks %>%
        rmapshaper::ms_simplify(keep=0.25, keep_shapes=TRUE) %>%
        dplyr::filter(SAPPARK_DATASITE!="NOT SUPPLIED FROM SAP") %>%
        dplyr::filter(!is.na(SAPPARK_DATASITE)) %>%
        sf::st_make_valid() %>%
        dplyr::filter(sf::st_geometry_type(.) %in% c("MULTIPOLYGON", "POLYGON"))

    message("Valid geoms: ", 100*mean(sf::st_is_valid(parks)), "%")
    parks %>% sf::st_geometry_type( )%>% table()
    parks = parks[sf::st_is_valid(parks),]
    saveRDS(parks, fs_parks)
}
if(!file.exists(fs_alcho)){
    alcho = sf::st_read(file.path(dir_data, 'alchohol.geojson'))
    alcho = alcho %>%
        rmapshaper::ms_simplify(keep=0.25) %>%
        sf::st_make_valid()
    saveRDS(alcho, fs_alcho)
}


cat(as.character(Sys.time()),' - loading alcho zones\n')
alcho = readRDS(fs_alcho)
cat(as.character(Sys.time()),' - loading parks\n')
parks = readRDS(fs_parks)

sf_use_s2(TRUE)

parks = parks %>% dplyr::filter(ParkExtentSHAPE_Area < quantile(parks$ParkExtentSHAPE_Area,c(0.999)))
