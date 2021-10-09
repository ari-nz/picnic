
# Server logic
server <- function(input, output,session) {

   points = Points$new()$reactive()
   last_intersection_ids = reactiveVal()
   active_shape_ids = reactiveVal()
   active_marker_ids = reactiveVal()



   observeEvent(input$basemap_click, {
      points()$add(input$basemap_click)

      active_shape_ids(points()$get()$pointId)
      active_marker_ids(points()$get()$pointId)

      leafletProxy('basemap') %>%
         addMarkers(
            data = points()$latest_record,
            lng = ~lng,
            lat = ~lat,
            layerId = ~pointId
         ) %>%
         addCircles(
            data = points()$latest_record,
            lng = ~lng,
            lat = ~lat,
            layerId = ~pointId,
            weight = 1,
            radius = input$distance*1000,
            fill =FALSE,
            color = '#000000'
         )



   })


   output$print_points = renderTable({
      points()$get()
   })

   observeEvent(input$add_record, {
      cp1 = list(lat = -36.8900555751941, lng = 174.754028320313, .nonce = 0.878921042598185)
      points()$add(cp1)
   })

   output$basemap = leaflet::renderLeaflet({
      lmap
   })

   refresh_map <- reactive({
      list(input$basemap_click,input$distance, input$reset)
   })

   observeEvent(points()$get_active(),{
      pts = points()$get_active()

      lpmap = leafletProxy('basemap')


      if(nrow(pts)>1){

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
         removeShape(active_shape_ids()) %>%
         removeMarker(active_marker_ids())
   })


   session$onSessionEnded(function() {
      cat("Data at end of session:\n",
         paste(
            capture.output(dput(isolate(points()$get()))),
            collapse='\n'
         )
      )
   })
   # onStop(function() {print(capture.output(dput(isolate(points()$get()))))})

}