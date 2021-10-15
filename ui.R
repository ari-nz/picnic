ui = bootstrapPage(

    tags$head(
        includeHTML("www/gtag.html"),
        includeCSS("www/styles.css"),
        includeScript("www/slider.js"),
        includeScript("www/misc.js")
    ),
shinyalert::useShinyalert(),

    navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
               HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">L3 with Picnics</a>'), id="nav",
               windowTitle = "L3 with Picnics",


               tabPanel("Picnics",
                        fluidRow(
                            column(2,offset=1,
                                   sliderInput('park_size', 'How big do you like your parks?',
                                               min = 1,max=5,value =c(1,5),step=1, ticks =FALSE),
                            ),
                            column(2,
                                   sliderInput('distance', 'How far are you really willing to go? (km)',
                                               min = 1,max=20,value =5,step=1,ticks = FALSE)
                            ),
                            column(2,
                                   #default text shows by default


                                   conditionalPanel("(typeof input.basemap_click == 'undefined')",
                                       h3(
                                           span("0 / 2 points selected")
                                       )
                                   ),


                                   conditionalPanel("typeof input.basemap_click !== 'undefined'",
                                       h3(
                                           textOutput("points_selected", inline = TRUE),
                                           span("/ 2 points selected")
                                       )
                                   )


                            ),
                            column(2,
                                   actionButton('shortest_path', 'Find me my parks!', class = 'btn-success')
                                   # checkboxInput('alcohol', 'Alcohol?')
                            ) %>% shiny::tagAppendAttributes(style="padding-bottom:10px"),
                            column(2,
                                   div(
                                       style="display:inline-block;float:right",
                                       actionButton('reset', div("Restart  ", icon("undo-alt")), class='btn-light')
                                   )
                            ) %>% shiny::tagAppendAttributes(style="padding-bottom:10px"),
                        ),
                        fluidRow(
                            column(width=10,offset = 1,
                                   shinycssloaders::withSpinner(
                                       leaflet::leafletOutput('basemap',width = "100%", height = '70vh'),
                                       type = 3, color = "#18bc9c", size = 2,color.background = 'white'
                                   )
                            )
                        ),
                        fluidRow(
                            column(11, offset=1,
                                   div("Built by",
                                       a("Ari Angelo", href= "https://www.linkedin.com/in/ariangelo/"),
                                       "with thanks to ",
                                       a("Charles Lan", href= "https://www.linkedin.com/in/charles-lan/"),
                                       " for the idea"
                                       ,style = 'font-color:#ced4da'
                                       )
                                   # tableOutput("print_points")
                            )
                        )
               )

    )
)

