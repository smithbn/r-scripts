#' A function to create a causal impact report from event data.
#'
#' This function creates one causal impact report.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' lift()
lift <- function(causal_data, data_start_date, test_start_date, season_number, season_duration){
  require('CausalImpact')
  require('lubridate')
  causal_data <- causal_data
  pre_period_end_date <- (ymd(test_start_date) - ymd(data_start_date)) - 1
  post_period_start_date <- pre_period_end_date + 1
  post_period_end_date <- length(causal_data[,1])
  pre.period <- c(1,pre_period_end_date)
  post.period <- c(post_period_start_date,post_period_end_date)
  impact <- CausalImpact(causal_data, pre.period, post.period, model.args = list(nseasons = season_number, season.duration = season_duration))
  options(max.print=99999999);
  options(width=120);
  print(summary(impact))
  print(summary(impact, "report"))
  png("dataplot.png", width= 1500)
      print(
        matplot(causal_data, type = "l")
    )
    dev.off()
  png("impactplot.png", width= 1500)
    print(
        plot(impact)
    )
    dev.off()
  invisible()
}