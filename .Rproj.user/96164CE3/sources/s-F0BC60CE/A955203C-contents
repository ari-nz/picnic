ui <- fluidPage(

    # Application title
    titlePanel("Level 3 with Picnics"),

    sidebarLayout(

        # Sidebar with a slider input
        sidebarPanel(
            sliderInput("obs",
                        "Number of observations:",
                        min = 0,
                        max = 1000,
                        value = 500)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            leaflet::leafletOutput('basemap')
        ),
        position ='right'
    )
)
