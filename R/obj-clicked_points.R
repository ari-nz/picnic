library(R6)
library(dplyr)


Points = R6::R6Class(
    classname = 'demopoints',

    private=list(
        #For shiny reactive deps
        reactiveDep = NULL,
        reactiveExpr = NULL,
        invalidate = function() {
            private$count <- private$count + 1
            private$reactiveDep(private$count)
            cat(private$count)
            invisible()
        },
        count = 0,

        #store clicked points and status
        clicked_points = tibble::tibble(
            lat =numeric(),
            lng = numeric(),
            active = logical(),
            pointId = integer()

        )

    ),


    public = list(

        initialize = function() {
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

        #Add points to df on click
        add = function(x) {

            private$clicked_points <- tibble::add_row(
                private$clicked_points,
                lat = x$lat,
                lng = x$lng,
                active=TRUE,
                pointId = nrow(private$clicked_points)+1
                )

            private$invalidate()

            invisible(self)
        } ,
        remove = function(id){
            private$clicked_points = dplyr::rows_update(
                private$clicked_points,
                tibble(pointId=id,active=FALSE)
                )
            private$invalidate()
            invisible(self)

        },

        #Print methods
        print = function() {
            cat("<Points>\n", sep = "")
            print(private$clicked_points)
            invisible(self)
        },
        get = function() {
            private$clicked_points
        },
        get_active = function(){
            # cat("Active <Points>\n", sep = "")
            s=private$clicked_points
            if(nrow(s)>0){
                s=s %>%
                    dplyr::filter(active)
            }

            s
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



