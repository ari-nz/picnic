
generate_intersections = function(points, distance = 5e3){
    zones_sf <- st_as_sf(points, coords = c("lng", "lat"), crs = 4326)
    buffers <- smoothr::smooth(st_buffer(zones_sf, dist = distance, nQuadSegs = 20),method = 'ksmooth',smoothness=10)
    buffer_int <- st_intersection(buffers)
    return(buffer_int)
}
