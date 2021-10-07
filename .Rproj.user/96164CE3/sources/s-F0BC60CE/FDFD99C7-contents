
# Server logic
server <- function(input, output,session) {
   output$basemap = leaflet::renderLeaflet({
       lmap = leaflet::leaflet() %>%
           leaflet::addTiles()

       lmap
   })
}