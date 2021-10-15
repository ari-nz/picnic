
generate_intersections = function(points, distance = 5e3){
    zones_sf <- st_as_sf(points, coords = c("lng", "lat"), crs = 4326) %>%
        sf::st_transform(2193)
    # buffers <- smoothr::smooth(st_buffer(zones_sf, dist = distance, nQuadSegs = 20),method = 'ksmooth',smoothness=10)
    buffers <- st_buffer(zones_sf, dist = distance, nQuadSegs = 40)
    buffer_int <- st_intersection(buffers) %>% sf::st_transform(4326)
    return(buffer_int)
}
