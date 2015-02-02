#' A function to create a causal impact report from event data in a time series format.
#'
#' This function creates one causal impact report.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' lift_ts()
lift_ts <- function(causal_data, data_start_date, test_start_date, season_number, season_duration){
    require('CausalImpact')
    require('lubridate')
    require('zoo')
    colnames(causal_data) <- c('Exposed','Control')
    time.points <- seq.Date(as.Date(ymd(data_start_date)), by = 1, length.out = length(causal_data[,1]))
    causal_data <- zoo(causal_data, time.points)
    season_number <- as.numeric(as.character(season_number))
    season_duration <- as.numeric(as.character(season_duration))
    pre_period_end_date <- as.Date(test_start_date) - 1
    post_period_start_date <- as.Date(test_start_date)
    post_period_end_date <- as.Date(ymd(data_start_date)) + length(causal_data[,1]) - 1  
    pre.period <- c(as.Date(data_start_date),pre_period_end_date)
    post.period <- c(post_period_start_date,post_period_end_date)
    impact <- CausalImpact(causal_data, pre.period, post.period, model.args = list(nseasons = season_number, season.duration = season_duration))
    options(max.print=99999999);
    options(width=120);
    print(summary(impact))
    print(summary(impact, "report"))
    png("dataplot.png", width= 1500)
    print(
        plot.zoo(
            causal_data,
            main = "Event Time Series",
            col = 'blue',
            xlab = NULL
        )
    )
    dev.off()
    png("impactplot.png", width= 1500)
    print(
        plot(impact)
    )
    dev.off()
    invisible()
}