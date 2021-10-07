ui = bootstrapPage(
    navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
               HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">L3 with Picnics</a>'), id="nav",
               windowTitle = "L3 with Picnics",

               sliderInput('distance', 'Distance',min = 2,max=20,value =5,step=1),
               #tags$head(includeCSS("styles.css")),

               tabPanel("Picnics",
                        leaflet::leafletOutput('basemap',width = "100%", height = 400),
                        verbatimTextOutput("cp")
               )

    )
)

