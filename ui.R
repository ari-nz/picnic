ui = bootstrapPage(
    navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
               HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">L3 with Picnics</a>'), id="nav",
               windowTitle = "L3 with Picnics",

               #tags$head(includeCSS("styles.css")),

               tabPanel("Picnics",
                        fluidRow(
                            h1("Click on the map to start")
                        ),
                        fluidRow(

                            column(width = 2,

                                   sliderInput('distance', 'Distance (km)',min = 2,max=20,value =5,step=1),
                                   actionButton('reset', 'reset'),
                                   actionButton('shortest_path', 'Show Shortest Path'),
                                   actionButton('isochrone', 'Show isochrone'),
                                   actionButton('add_record','Add Record'),
                            ),


                            column(width=10,
                                   leaflet::leafletOutput('basemap',width = "100%", height = 400)
                            )
                        ),
                        fluidRow(

                            tableOutput("print_points")
                        )
               )

    )
)

