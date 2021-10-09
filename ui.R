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

                                   actionButton('reset', 'reset'),
                                   sliderInput('park_size', 'How big do you like your parks?',min = 1,max=5,value =c(1,5),step=1),
                                   sliderInput('distance', 'How far are you really willing to go? (km)',min = 1,max=20,value =5,step=1),
                                   actionButton('shortest_path', 'Show Shortest Path'),
                                   actionButton('closest_parks', 'Find me my parks!'),
                                   checkboxInput('alcohol', 'Do you like Alcohol?')
                                   # actionButton('isochrone', 'Show isochrone'),
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

