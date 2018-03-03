#' A simple Reference Class Definition to represent sampleInfoClass.
#'
#' @field vector A numeric vector
#' @field vectorMetrics List of arbitrary metrics of the vector
sampleInfoClass <- setRefClass("sampleInfoClass", 
                               fields = list(vector = "numeric", vectorMetrics = "list"))


#' A Reference Class Definition with Initializer to represent sampleInfoClass.
#'
#' @field vector A numeric vector
#' @field vectorMetrics List of arbitrary metrics of the vector
sampleInfoClass <-
    setRefClass("sampleInfoClass",
        fields = list(vector = "numeric", vectorMetrics = "list"),
        methods = list(
            initialize = function(vector = NA, vectorMetrics = NA) {
                .self$vector <- vector
                .self$vectorMetrics <- vectorMetrics
                .self$message()
            },
            message = function() {
                cat("New sampleInfoClass instance created.")
            }
        )
    )

#' A Reference Class Definition to represent collection of sampleInfoClass.
#'
#' @include sampleInfoClass
#' @field sampleInfoClasses A list of sampleInfoClasses.
sampleInfoCollectionClass <-
    setRefClass("sampleInfoCollectionClass",
        fields = list(sampleInfoClasses = "list"),
        methods = list(
            initialize = function(sampleInfoClasses = NA) {
                "Construct an instance of sampleInfoCollectionClass after validating the type."
                
                if (class(sampleInfoClasses[[1]]) != "sampleInfoClass") {
                    stop("Incompatible input type. Provide a list of sampleInfoClass")
                }
                .self$sampleInfoClasses <- sampleInfoClasses
                .self$message()
            },
            
            message = function() {
                cat("New sampleInfoCollectionClass instance created.")
            }
        )
    )

sampleInfoCollectionClass$methods(
    calculateScalar = function(FUN = mean, ...) {
        "Computes a scalar metric from a numeric vectorm and assigns to the object"
        
        nameOfFun <- gsub("[^[:alnum:]]", "", gsub("UseMethod", "", deparse(FUN)[2], fixed = T))
        
        lapply(sampleInfoClasses, function(x) {
            x$vectorMetrics[[nameOfFun]] <- FUN(x$vector)
        })
    }
)

sampleInfoCollectionClass$methods(
    generatePlot = function(metric = "mean", plotFun = barplot, ...) {
        "Creates a barplot by extracting the named metric from each object"
        
        if (is.null(sampleInfoClasses[[1]]$vectorMetrics[[metric]])) {
            stop(paste(metric, "not calculated yet!"))
        }
        
        df <- data.frame(unlist(
            lapply(sampleInfoClasses, function(x) {
                x$vectorMetrics[[metric]]
            })
        ))
        
        plotFun(df[, 1], ...)
    }
)

sampleInfoCollectionClass$methods(
    plotToHTML = function(file = "index.html"){
        "Generates an html page from the plot created in generatePlot() function"
        
        require(R2HTML)
        HTMLplot(file = file, append = F)
        cat(paste("Plot is saved to ", getwd()))
    }   
)
