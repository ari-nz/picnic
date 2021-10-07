
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


   })


   observeEvent(input$reset,{
      clicked_points(list())
      leafletProxy('basemap') %>%
         clearShapes() %>%
         clearMarkers()
   })

   refresh_map <- reactive({
      list(input$basemap_click,input$distance, input$reset)
   })

   observeEvent(refresh_map(),{

      cp = clicked_points()
      req(length(cp)>0)
      cp_df = do.call(rbind.data.frame, cp)

   print(cp_df)
   lpmap =     leafletProxy('basemap') %>%
      clearShapes() %>%
      clearMarkers() %>%
      addMarkers(data = cp_df, lng = ~lng, lat = ~lat) %>%
      addCircles(
         lng = ~lng,
         lat = ~lat,
         weight = 1,
         data = cp_df,
         radius = input$distance*1000,
         fill =FALSE,
         color = '#000000'

      )

   if(length(cp)>1){
      intersections = generate_intersections(cp, input$distance*1000) %>%
         dplyr::filter(n.overlaps > 1)

      lpmap = lpmap %>%
         addPolygons(data = intersections, stroke = FALSE)
   }


      lpmap
   })




}