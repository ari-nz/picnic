ui = bootstrapPage(
    navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
               HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">L3 with Picnics</a>'), id="nav",
               windowTitle = "L3 with Picnics",

               tags$head(
                   includeCSS("www/gtag.html"),
                   includeCSS("www/styles.css"),
                   includeScript("www/slider.js")
                   ),
               tabPanel("Picnics",
                        fluidRow(
                            column(3,offset=1,
                                   sliderInput('park_size', 'How big do you like your parks?',min = 1,max=5,value =c(1,5),step=1, ticks =FALSE),
                                   textOutput('blah')
                                   ),
                            column(3,
                                   sliderInput('distance', 'How far are you really willing to go? (km)',min = 1,max=20,value =5,step=1)
                                   ),

                            column(2,
                                   actionButton('shortest_path', 'Find me my parks!', class = 'btn-success')
                                   # actionButton('reset', div("Restart  ", icon("undo-alt")), class='btn-light')
                            ) %>% shiny::tagAppendAttributes(style="padding-bottom:10px"),
                            column(2,
                                   # actionButton('shortest_path', 'Find me my parks!', class = 'btn-success'),
                                   div(style="display:inline-block",
                                       actionButton('reset', div("Restart  ", icon("undo-alt")), class='btn-light')
                                       , style="float:right")
                            ) %>% shiny::tagAppendAttributes(style="padding-bottom:10px"),
                        ),
                        fluidRow(




                            column(width=10,offset = 1,
                                   leaflet::leafletOutput('basemap',width = "100%", height = '70vh')
                            )
                        ),
                        fluidRow(

                            tableOutput("print_points")
                        )
               )

    )
)

