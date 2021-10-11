
# Server logic
server <- function(input, output,session) {

   points = Points$new()$reactive()
   last_intersection_ids = reactiveVal()
   last_closestpark_ids = reactiveVal()
   route = reactiveVal()



   output$basemap = leaflet::renderLeaflet({

      lmap
   })



   observeEvent(input$basemap_click, {
      click = sf::st_sfc(sf::st_point(c(input$basemap_click$lng, input$basemap_click$lat)), crs = 4326)
      if(sf::st_within(click,aucks,sparse = FALSE)[1]){
         points()$add(input$basemap_click)
         points()$limit_records(2)
      }
   })





   #Show hide groups to not re-render map.
   #Requires character group names, but useing group size for convenience
   observeEvent(input$park_size, {

      chosen_sizes = seq(input$park_size[1], input$park_size[2])
      hidden_sizes =setdiff(1:5, chosen_sizes)

      lpmap =  leafletProxy('basemap')
      if(length(chosen_sizes)>0){
         for (i in chosen_sizes){lpmap = showGroup(lpmap, as.character(i))}
      }

      if(length(hidden_sizes)>0){
         for (i in hidden_sizes){lpmap = hideGroup(lpmap, as.character(i))}
      }

      lpmap
   })



   #remove marker on click
   observeEvent(input$basemap_marker_click, {
      id = as.numeric(gsub("M", "", input$basemap_marker_click$id))
      points()$remove(id)

      leafletProxy('basemap') %>%
         leaflet::removeShape(last_intersection_ids())%>%
         leaflet::removeShape(last_closestpark_ids())

   })


   observeEvent(input$shortest_path, {

      if(nrow(points()$get_active())<2){
         shinyalert("Oops!", "You'll need to have at least 2 points chosen on the map ", type = "error")
         return(NULL)
      }



      route(Route$new(points()))

      rte = route()
      filtered_parks = parks %>% dplyr::filter(GROUPING %in% seq(input$park_size[1], input$park_size[2]))

      sf::st_nearest_feature(rte$sp_env$midpoint, filtered_parks)
      nn_df= nngeo::st_nn(
         rte$sp_env$midpoint,
         filtered_parks,
         k = 5,
         maxdist = 1000,
         progress = FALSE,
         returnDist = TRUE
         ) %>%
         unlist(recursive = FALSE) %>%
         as.data.frame
      nn_idx = nn_df$nn

      if(length(nn_idx)==0){
         nn_idx = nngeo::st_nn(rte$sp_env$midpoint, filtered_parks,k = 1,progress = FALSE,returnDist = TRUE) %>%
            unlist(recursive = FALSE) %>%
            as.data.frame %>%
            .$nn
      }



      filter_parks = filtered_parks[nn_idx,]


      lpmap = leafletProxy('basemap') %>%
         leaflet::removeShape("shortestpath") %>%
         leaflet::removeShape(last_closestpark_ids()) %>%
         leaflet::removeMarker("midpoint") %>%
         leaflet::addPolylines(
            data = route()$sp_env$shortest_path_route,
            layerId = "shortestpath",
            opacity = 1,
            color = "#417d29"
         ) %>%
         leaflet::addCircleMarkers(
            data = route()$sp_env$midpoint,
            layerId = 'midpoint',
            color = "#417d29"
         )%>%
         leaflet::addPolygons(
            data = filter_parks,
            layerId = ~PID,
            fill = FALSE,
            color = '#000',
            popup = ~SAPPARK_DATADESCRIPTION
         )

      suppressWarnings({
      # chosen_park_data = sf::st_union(filter_parks) %>% sf::st_bbox()
      pnt = sf::st_union(filter_parks) %>% sf::st_centroid() %>% sf::st_coordinates()
      lpmap = lpmap %>%
         flyTo(
            lng=pnt[1],
            lat=pnt[2],
            zoom = 14
         )
         # flyToBounds(
         #    lng1 = chosen_park_data[1],
         #    lat1 = chosen_park_data[2],
         #    lng2 = chosen_park_data[3],
         #    lat2 = chosen_park_data[4],
         #    )
})
      last_closestpark_ids(filter_parks$PID)

      lpmap
   })

   # observeEvent(input$closest_parks, {
   #    #need to ensure routes been created
   #
   #
   # })


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


   # output$print_points = renderTable({
   #    points()$get()
   # })

   # observeEvent(input$add_record, {
   #    cp1 = list(lat = -36.8900555751941, lng = 174.754028320313, .nonce = 0.878921042598185)
   #    points()$add(cp1)
   # })



   refresh_map <- reactive({
      list(points()$get_active(),input$distance)
   })



   observeEvent(refresh_map(), {
      pts = points()$get_active()
      old_pts = points()$get_inactive()

      lpmap = leafletProxy('basemap')


      #Remove older circles if active points change
      if(nrow(old_pts)>0){
         old_marker_id = paste0("M", old_pts$pointId)
         old_circle_id = paste0("C", old_pts$pointId)


         lpmap=lpmap %>%
            leaflet::removeMarker(old_marker_id) %>%
            leaflet::removeShape(old_circle_id) %>%
            leaflet::removeShape("shortestpath") %>%
            leaflet::removeMarker("midpoint")
      }

      # Add markers and circle with uids
      marker_id = paste0("M", pts$pointId)
      circle_id = paste0("C", pts$pointId)


      lpmap = lpmap %>%
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
            leaflet::removeShape(last_intersection_ids()) %>%
            leaflet::removeShape(last_closestpark_ids()) %>%
            leaflet::removeMarker("midpoint") %>%
            leaflet::addPolygons(data = intersections,
                        stroke = FALSE,
                        fillColor = ~pal(n.overlaps),
                        layerId = ~DIID,
                        options = pathOptions(pane = "intersection")
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

      lpmap = leafletProxy('basemap')
      if(nrow(points()$get())>0){

         points()$remove(seq(points()$total_records))
         lpmap %>%
            removeShape(last_intersection_ids()) %>%
            removeShape(last_closestpark_ids()) %>%
            removeShape(paste0("C",points()$get()$pointId)) %>%
            removeMarker(paste0("M",points()$get()$pointId)) %>%
            leaflet::removeShape("shortestpath") %>%
            leaflet::removeMarker("midpoint")
      }

      lpmap %>%
         leaflet::flyTo(174.757,-36.847,zoom = 11)

   })



   observeEvent(input$alcohol, {
      if(input$alcohol == TRUE){
         leafletProxy('basemap') %>%
            leaflet::addPolygons(
               data = alcho,
               fillColor  = ~HOURCOL,
               stroke=FALSE,
               fillOpacity = 0.5,
               layerId = ~paste0("alcho", GlobalID ),
               label  = ~label,
               labelOptions = labelOptions(
                  direction = "bottom",
                  style = list()
               ),
               options = pathOptions(pane = "alcho")
            ) %>%
            addLegend(
               colors = unique(alcho$HOURCOL),
               labels = unique(alcho$HOUROPS),
               opacity = 1,
               layerId  = 'alcholeg'
            )
      } else {
         leafletProxy('basemap') %>%
            removeShape(
               ~paste0("alcho", GlobalID )
            )
      }
   },ignoreInit = TRUE)



   session$onSessionEnded(function() {
      cat("Data at end of session:\n",
          paste(
             capture.output(dput(isolate(points()$get()))),
             collapse='\n'
          ),
          "\n",
          paste(
             capture.output(isolate(points()$get())),
             collapse='\n'
          )
      )
   })

}