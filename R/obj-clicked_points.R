library(R6)
library(dplyr)

Points = R6::R6Class(
    classname = 'demopoints',

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
            if(nrow(private$clicked_points)>0){
                private$clicked_points %>%
                    dplyr::filter(active)
            } else {
                private$clicked_points
            }

        }


    ),

    active = list(
        total_records = function(value) {
            if (missing(value)) {

            }

            nrow(private$clicked_points)
        },
        active_records = function(value) {
            if (missing(value)) {

            }

            nrow(dplyr::filter(private$clicked_points,active))
        },
        latest_record = function(){
            tail(private$clicked_points,1)
        }
    )
)




#Reactive Shiny
if(FALSE){



cp1 = list(lat = -36.8900555751941, lng = 174.754028320313, .nonce = 0.878921042598185)
p =Points$new()
p$add(cp1)
pr <- p$reactive()
# The observer accesses the reactive expression
o <- observe({
    message("Point added:")
})
shiny:::flushReact()

#> Person changed. Name: Dean

# Note that this is in isolate only because we're running at the console; in
# typical Shiny code, the isolate() wouldn't be necessary.
isolate(pr()$add(cp1))
shiny:::flushReact()
}



