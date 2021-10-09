library(R6)
library(dplyr)

Routes = R6::R6Class(
    classname = 'routing',

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

    ),

    active = list(


        shortest_path = function(){

            if(self$active_records==2){
                data = self$get_active()
                pt1 = c(data$lng[1], data$lat[1])
                pt2 = c(data$lng[2], data$lat[2])
                route <- osrm::osrmRoute(
                    src = pt1,
                    dst = pt2,
                    overview = "full",
                    returnclass = "sf",
                    osrm.profile='bike'
                )

            } else {
                route=NULL
            }
            route



        },
        isochrone = function(){


            if(self$active_records>=1){
                data = self$latest_record
                pt1 = c(data$lng[1], data$lat[1])
                message("Off getting isochrones")
                iso = osrm::osrmIsometric(pt1, breaks = c(0,3,5,10)*1e3, osrm.profile='bike')


            } else {
                iso=NULL
            }
            iso

        }


    )
)

