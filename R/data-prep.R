
library(dplyr)
library(rmapshaper)
library(sf)

dir_data = 'data'
fs_parks = file.path(dir_data, 'parks.rds')
fs_alcho = file.path(dir_data, 'alchohol.rds')
fs_aucks = file.path(dir_data, 'auckland.rds')

sf_use_s2(TRUE)
if(!file.exists(fs_parks)){
    parks = sf::st_read(file.path(dir_data, 'parks.geojson'))
    parks = parks %>%
        dplyr::filter(SAPPARK_DATASITE!="NOT SUPPLIED FROM SAP") %>%
        dplyr::filter(!is.na(SAPPARK_DATASITE)) %>%
        rmapshaper::ms_simplify(keep=0.25, keep_shapes=TRUE) %>%
        sf::st_make_valid() %>%
        dplyr::filter(sf::st_geometry_type(.) %in% c("MULTIPOLYGON", "POLYGON")) %>%
        sf::st_transform(4326)

    message("Valid geoms: ", 100*mean(sf::st_is_valid(parks)), "%")
    parks %>% sf::st_geometry_type( )%>% table()
    parks = parks[sf::st_is_valid(parks),]
    saveRDS(parks, fs_parks)
}
if(!file.exists(fs_aucks)){
    aucks = sf::st_read(file.path(dir_data, 'raw-tas.gdb'))

    aucks = aucks %>%
        dplyr::filter(TA2020_V1_00_NAME=='Auckland') %>%
        rmapshaper::ms_simplify(keep=0.01, keep_shapes=TRUE) %>%
        sf::st_buffer(5e3) %>%
        sf::st_make_valid() %>%
        sf::st_transform(4326)

    saveRDS(parks, fs_aucks)
}


if(!file.exists(fs_alcho)){
    alcho = sf::st_read(file.path(dir_data, 'alchohol.geojson'))
    alcho = alcho %>%
        rmapshaper::ms_simplify(keep=0.25) %>%
        sf::st_make_valid() %>%
        sf::st_transform(4326)

    alcho$label = lapply(
        paste("<b>",alcho$BYLAWTITLE,"</b><br/>",alcho$HOURSOFOPERATION ),
        htmltools::HTML
    )


    alcho = alcho %>%
        dplyr::mutate(HOUROPS = forcats::fct_lump_prop(HOURSOFOPERATION, prop = 0.1)) %>%
        dplyr::mutate(HOUROPS =  forcats::fct_recode(HOUROPS, "10pm-7am / 7am-7pm" = "10pm to 7am during daylight saving and 7pm to 7am outside daylight saving")) %>%
        dplyr::mutate(HOURCOL =  case_when(
            HOUROPS == "10pm-7am(NZDT)/7am-7pm(NZST)" ~ "#c29f4c",
            HOUROPS == "24 hours, 7 days a week" ~ "#b662d1",
            HOUROPS == "7pm to 7am daily" ~ "#d75e63",
            HOUROPS == "Other" ~ "#9b99bc"
        ))



    saveRDS(alcho, fs_alcho)

}





cat(as.character(Sys.time()),' - loading alcho zones\n')
alcho = readRDS(fs_alcho)
cat(as.character(Sys.time()),' - loading parks\n')
parks = readRDS(fs_parks)
cat(as.character(Sys.time()),' - loading aucks\n')
parks = readRDS(fs_aucks)

sf_use_s2(TRUE)

parks = parks %>% dplyr::filter(ParkExtentSHAPE_Area < quantile(parks$ParkExtentSHAPE_Area,c(0.999)))
