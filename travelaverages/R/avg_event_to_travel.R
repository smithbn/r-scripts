#' A Cat Function
#'
#' This function allows you to express your love of cats.
#' @param love Do you love cats? Defaults to TRUE.
#' @keywords cats
#' @export
#' @examples
#' avg_event_to_travel()
avg_event_to_travel <- function(x){
  data <- subset(x, event_type=='FLIGHT_CONFIRMATION' & event_to_travel!='NULL')
  colnames(data) <- c('event_date','event_type','partner','origin_airport','destination_airport','number_of_travelers','departure_date','return_date','duration','event_to_travel','num_events')
  all_days <- data.frame(rep(data$event_to_travel, times=data$num_events))
  colnames(all_days)<-'event_to_travel'
  avg_days<-mean(as.numeric(all_days$event_to_travel))
  return(avg_days)
}