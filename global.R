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


alcho = readRDS(fs_alcho)
parks = readRDS(fs_parks)
parks = parks %>% dplyr::filter(ParkExtentSHAPE_Area < quantile(parks$ParkExtentSHAPE_Area,c(0.999)))

clicked_points = list()




lmap = leaflet::leaflet(data = parks) %>%
    leaflet::addProviderTiles(provider = leaflet::providers$CartoDB.Positron) %>%
    leaflet::setView(174.757,-36.847,zoom = 10) %>%
    leaflet::addPolygons(stroke=FALSE, fillColor = "#5fd5a7", fillOpacity  = 1)# %>%
    # leaflet::addPolygons(stroke=FALSE, fillColor = "#FFA500", fillOpacity  = 0.7, data = alcho)




# cp = list(list(lat = -36.8900555751941, lng = 174.754028320313, .nonce = 0.878921042598185),
#           list(lat = -36.9219008721262, lng = 174.821319580078, .nonce = 0.891240011649733),
#           list(lat = -36.8636907959613, lng = 174.829559326172, .nonce = 0.453579001691568))
#

generate_intersections = function(points, distance = 5e3){
    zones = do.call(rbind.data.frame, points)

    zones_sf <- st_as_sf(zones, coords = c("lng", "lat"), crs = 4326)

    buffers <- smoothr::smooth(st_buffer(zones_sf, dist = distance, nQuadSegs = 20),method = 'ksmooth',smoothness=10)
    # Intersect the circles with the polygons
    buffer_int <- st_intersection(buffers)
    buffer_int
}


#
# cp = tribble(
#     ~lat ,     ~lng ,   ~.nonce,
#      -36.90049 ,174.7691, 0.9062808,
#      -36.88731 ,174.6455, 0.8194645,
#      -36.88951 ,174.8982, 0.1318054,
#      -36.98720 ,174.7691, 0.3483685
# )
#

