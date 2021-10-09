library(R6)
library(shiny)

Person <- R6::R6Class(
    "Person",
    private = list(
        clicked_points = tibble::tibble(
                lat =numeric(),
                lng = numeric(),
                active = logical(),
                pointId = integer()

            ),
        reactiveDep = NULL,
        reactiveExpr = NULL,
        invalidate = function() {
            private$count <- private$count + 1
            private$reactiveDep(private$count)
            invisible()
        },
        count = 0
    ),
    public = list(
        initialize = function(clicked_points=tibble::tibble(
            lat =numeric(),
            lng = numeric(),
            active = logical(),
            pointId = integer()

        )) {
            # Until someone calls $reactive(), private$reactiveDep() is a no-op. Need
            # to set it here because if it's set in the definition of private above, it will
            # be locked and can't be changed.
            private$reactiveDep <- function(x) NULL
            private$clicked_points <- clicked_points
        },
        reactive = function() {
            # Ensure the reactive stuff is initialized.
            if (is.null(private$reactiveExpr)) {
                private$reactiveDep <- reactiveVal(0)
                private$reactiveExpr <- reactive({
                    private$reactiveDep()
                    self
                })
            }
            private$reactiveExpr
        },
        print = function() {
            cat("<Points>:", str(private$clicked_points))
        },
        add = function(x) {
            private$clicked_points <- tibble::add_row(
                private$clicked_points,
                lat = x$lat,
                lng = x$lng,
                active=TRUE,
                pointId = nrow(private$clicked_points)+1
            )
            private$invalidate()
        },
        get = function() {
            private$clicked_points
        },

        remove = function(id){
            private$clicked_points = dplyr::rows_update(
                private$clicked_points,
                tibble(pointId=id,active=FALSE)
            )
            private$invalidate()

        },
        get_active = function(){
            # cat("Active <Points>\n", sep = "")
            if(nrow(s)>0){
                private$clicked_points %>%
                     dplyr::filter(active)
            } else {
                private$clicked_points
            }

        }


        )
    )


    library(shiny)

    ui <- fluidPage(
        actionButton('cn','ChangeName'),
        textOutput('name')
    )

    server <- function(input, output, session) {
        pr <- Person$new()$reactive()

        # The observer accesses the reactive expression
        observeEvent(pr()$get(), {
            message("Person changed. Name: ", str(pr()$get())  )
        })
        output$name = renderText({
            str(pr()$get())
        })

        observeEvent(input$cn, {
            cp1 = list(lat = -36.8900555751941, lng = 174.754028320313, .nonce = 0.878921042598185)
            pr()$add(cp1)
        })

    }

    shinyApp(ui, server)