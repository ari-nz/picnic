
# Server logic
server <- function(input, output,session) {

    clicked_points = reactiveVal(list())
    output$cp = renderText({capture.output(dput(clicked_points()))})

   output$basemap = leaflet::renderLeaflet({
       lmap
   })


   observeEvent(input$basemap_click, {
       click = input$basemap_click
       clicked_points(c(clicked_points(), list(click)))
       cp = clicked_points()
       cp_df = do.call(rbind.data.frame, cp)

       lpmap = leafletProxy('basemap')%>%
           addMarkers(lng = click$lng, lat = click$lat)


       # if (length(cp)>0){
           lpmap = lpmap %>%
               addCircles(
                   lng = ~lng,
                   lat = ~lat,
                   weight = 1,
                   data = cp_df,
                   radius = input$distance*1000,
                   fill =FALSE,
                   color = '#000000'
               )
       # }

       if(length(cp)>1){
           intersections = generate_intersections(cp, input$distance*1000) %>%
               dplyr::filter(n.overlaps > 1)
           lpmap %>%
               addPolygons(data = intersections)
       }

    lpmap


   })


}