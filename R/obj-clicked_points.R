library(R6)
library(dplyr)


.basic_table = tibble::tibble(
    lat =numeric(),
    lng = numeric(),
    active = logical(),
    pointId = integer()

)

Points = R6::R6Class(
    classname = 'demopoints',

    private = list(
        clicked_points = .basic_table,
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
        initialize = function(clicked_points = .basic_table) {
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
            if(!is.na(id)){# turns out that clickign a circle marker counts as a marker with an id of NA
                private$clicked_points = dplyr::rows_update(
                    private$clicked_points,
                    tibble(pointId=id,active=FALSE)
                )
                private$invalidate()
            }
        },
        get_active = function(){
            # cat("Active <Points>\n", sep = "")
            if(nrow(private$clicked_points)>0){
                private$clicked_points %>%
                    dplyr::filter(active)
            } else {
                private$clicked_points
            }

        },
        get_inactive = function(){
            # cat("Active <Points>\n", sep = "")
            if(nrow(private$clicked_points)>0){
                private$clicked_points %>%
                    dplyr::filter(!active)
            } else {
                private$clicked_points
            }

        },
        limit_records = function(limit_value){
            #limit to latest records as chose
            if(sum(private$clicked_points$active) > limit_value){
                keep_index = tail(which(private$clicked_points$active),limit_value)
                private$clicked_points$active = FALSE
                private$clicked_points$active[keep_index] = TRUE

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

        # shortest_path = function(){
        #
        #     if(self$active_records==2){
        #         data = self$get_active()
        #         pt1 = c(data$lng[1], data$lat[1])
        #         pt2 = c(data$lng[2], data$lat[2])
        #         route <- osrm::osrmRoute(
        #             src = pt1,
        #             dst = pt2,
        #             overview = "full",
        #             returnclass = "sf",
        #             osrm.profile='bike'
        #         )
        #
        #     } else {
        #         route=NULL
        #     }
        #     route
        #
        #
        #
        #  },
        # isochrone = function(){
        #
        #
        #     if(self$active_records>=1){
        #         data = self$latest_record
        #         pt1 = c(data$lng[1], data$lat[1])
        #         message("Off getting isochrones")
        #         iso = osrm::osrmIsometric(pt1, breaks = c(0,3,5,10)*1e3, osrm.profile='bike')
        #
        #
        #     } else {
        #         iso=NULL
        #     }
        #     iso
        #
        # }


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



