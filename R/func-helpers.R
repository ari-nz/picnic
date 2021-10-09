
generate_intersections = function(points, distance = 5e3){
    zones = do.call(rbind.data.frame, points)

    zones_sf <- st_as_sf(zones, coords = c("lng", "lat"), crs = 4326)

    buffers <- smoothr::smooth(st_buffer(zones_sf, dist = distance, nQuadSegs = 20),method = 'ksmooth',smoothness=10)
    # Intersect the circles with the polygons
    buffer_int <- st_intersection(buffers)
    buffer_int
}
