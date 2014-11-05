#' A function to create a causal impact plot from event data.
#'
#' This function creates the causal impact time series plot.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' impactplot()
impactplot <- function(impact){
    png("impactplot.png", width= 1500)
    print(
        plot(impact)
    )
    dev.off()
  #return nothing
  invisible();  
}