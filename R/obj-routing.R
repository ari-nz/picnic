library(R6)
library(dplyr)

Route = R6::R6Class(
    classname = 'routing',

    private = list(

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


        initialize = function(points, source, dest){

            if(!missing(points)){
                stopifnot(any(class(points)%in%'demopoints'))

                data = points$get() %>%
                    dplyr::filter(active)
                stopifnot(nrow(data)==2)

                self$source = c(data$lng[1], data$lat[1])
                self$dest = c(data$lng[2], data$lat[2])

            }
            if (!missing(source) && !missing(dest) && missing(points)){
                self$source = source
                self$dest = dest
            }


            self$sp_env$shortest_path_route = self$shortest_path

            # Until someone calls $reactive(), private$reactiveDep() is a no-op. Need
            # to set it here because if it's set in the definition of private above, it will
            # be locked and can't be changed.
            private$reactiveDep <- function(x) NULL
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


        source = NULL,
        dest = NULL,
        sp_env = list(
            midpoint = NULL,
            shortest_path_distance = NULL,
            shortest_path_direct = NULL,
            shortest_path_time = NULL,
            shortest_path_route = NULL
        )
    ),

    active = list(


        shortest_path = function(){

            route <- osrm::osrmRoute(
                src = self$source,
                dst = self$dest,
                overview = "full",
                returnclass = "sf",
                osrm.profile='bike'
            )

            self$sp_env$shortest_path_distance = sf::st_length(route)
            self$sp_env$shortest_path_direct = sf::st_distance(
                sf::st_sfc(sf::st_point(self$source)) %>% sf::st_set_crs(4326),
                sf::st_sfc(sf::st_point(self$dest)) %>% sf::st_set_crs(4326)
            )
            self$sp_env$shortest_path_time = route$duration

            center = suppressWarnings(sf::st_centroid(route))
            nearest_line = sf::st_nearest_points(center, route)
            nearest_point = tail(sf::st_cast(nearest_line, "POINT"),1)
            self$sp_env$midpoint = nearest_point

            #mapview::mapview(sf::st_nearest_points(center, route))+  mapview::mapview(center) +  mapview::mapview(route)
            # mapview::mapview(route)+  mapview::mapview(nearest_point)
            route


        }



    )
)

