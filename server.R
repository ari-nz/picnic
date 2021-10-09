
# Server logic
server <- function(input, output,session) {

   points = Points$new()$reactive()
   last_intersection_ids = reactiveVal()
   route = reactiveVal()


   observeEvent(input$basemap_click, {
      points()$add(input$basemap_click)
      points()$limit_records(2)
   })


   observeEvent(input$shortest_path, {
      route(Route$new(points()))

      leafletProxy('basemap') %>%
         leaflet::removeShape("shortestpath") %>%
         leaflet::removeShape("midpoint") %>%
         leaflet::addPolylines(
            data = route()$sp_env$shortest_path_route,
            layerId = "shortestpath"
         ) %>%
         leaflet::addCircleMarkers(
            data = route()$sp_env$midpoint,
            layerId = 'midpoint'
         )


   })
   observeEvent(input$closest_parks, {
   #need to ensure routes been created
      rte = route()
      sf::st_nearest_feature(rte$sp_env$midpoint, parks)
      nn_idx= unlist(nngeo::st_nn(rte$sp_env$midpoint, parks,k = 5,maxdist = 1000,progress = FALSE))


      leafletProxy('basemap') %>%
         leaflet::addPolygons(data = parks[nn_idx,],
                              layerId = paste0("P",nn_idx))


   })
   # observeEvent(input$isochrone, {
   #    chronos = points()$isochrone
   #
   #    leafletProxy('basemap') %>%
   #       leaflet::removeShape(letters[1:3]) %>%
   #       leaflet::addPolylines(
   #          data = chronos,
   #          layerId = letters[1:3]
   #       )
   #
   #
   # })


   output$print_points = renderTable({
      points()$get()
   })

   # observeEvent(input$add_record, {
   #    cp1 = list(lat = -36.8900555751941, lng = 174.754028320313, .nonce = 0.878921042598185)
   #    points()$add(cp1)
   # })

   output$basemap = leaflet::renderLeaflet({
      lmap
   })


   refresh_map <- reactive({
      list(points()$get_active(),input$distance)
   })

   observeEvent(refresh_map(), {
      pts = points()$get_active()
      old_pts = points()$get_inactive()

      lpmap = leafletProxy('basemap')



      #Remove older circles
      if(nrow(old_pts)>0){
         old_marker_id = paste0("M", old_pts$pointId)
         old_circle_id = paste0("C", old_pts$pointId)


         lpmap %>%
            leaflet::removeMarker(old_marker_id) %>%
            leaflet::removeShape(old_circle_id) %>%
            leaflet::removeShape("shortestpath") %>%
            leaflet::removeShape("midpoint")
      }

      # Add markers and circle with uids
      marker_id = paste0("M", pts$pointId)
      circle_id = paste0("C", pts$pointId)


      lpmap %>%
         addMarkers(
            data = pts,
            lng = ~lng,
            lat = ~lat,
            layerId = marker_id
         ) %>%
         addCircles(
            data = pts,
            lng = ~lng,
            lat = ~lat,
            layerId = circle_id,
            weight = 1,
            radius = input$distance*1000,
            fill =FALSE,
            color = '#000000'
         )







      #Add overlaps if necessary

      if(nrow(pts)>=2){

         intersections = generate_intersections(pts, input$distance*1000) %>%
            dplyr::filter(n.overlaps > 1) %>%
            dplyr::mutate(DIID = paste0(points()$total_records,"_", row_number()))

         pal <- colorNumeric("YlOrRd", domain = intersections$n.overlaps)


         lpmap = lpmap %>%
            removeShape(last_intersection_ids()) %>%
            addPolygons(data = intersections,
                        stroke = FALSE,
                        fillColor = ~pal(n.overlaps),
                        layerId = ~DIID
                        # highlightOptions = highlightOptions(
                        #    color = "black",
                        #    weight = 2,
                        #    bringToFront = TRUE
                        # )
            )

         #Store ID's for removal later
         last_intersection_ids(intersections$DIID)

      }


      lpmap
   })

   observeEvent(input$reset,{
      points()$remove(seq(points()$total_records))
      leafletProxy('basemap') %>%
         removeShape(last_intersection_ids()) %>%
         removeShape(paste0("C",points()$get()$pointId)) %>%
         removeMarker(paste0("M",points()$get()$pointId)) %>%
         leaflet::removeShape("shortestpath")
   })


   session$onSessionEnded(function() {
      cat("Data at end of session:\n",
          paste(
             capture.output(dput(isolate(points()$get()))),
             collapse='\n'
          )
      )
   })

}