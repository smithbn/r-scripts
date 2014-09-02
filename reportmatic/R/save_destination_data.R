#' A function to check if the file is a csv and if it is to upload it to a sqlite database for safekeeping.
#'
#' This function allows you to save the data into a sqlite database.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' save_destination_data()
save_destination_data <- function(file, ...){

library('lubridate')
library('sqldf')
library('ggplot2')
library('plyr')
library('timeDate')
library('grid')

#----------------------------------
# Load the uu counts
#----------------------------------

exposed_uu_count <- as.numeric(1712647.00) 
control_uu_count <- as.numeric(0.00) 

#----------------------------------
# List of All Airports
#----------------------------------
airports <- read.csv(file, header=F)
colnames(airports) <- c("icao", "iata", "airport_name", "city", "state", "country")

#----------------------------------
# Calculate Exposed Events for the Destination
#----------------------------------
#exposed_events_for_destination <- event_data[which(event_data$destination_airport %in% destination_airport_list[,1] | ( event_data$hotel_city %in% destination_city_list[,1] &  event_data$hotel_state %in% destination_state_list[,1]) | event_data$rental_city %in% destination_city_list[,1] | event_data$rental_city %in% destination_airport_list[,1] | event_data$vacation_airport_destination %in% destination_airport_list[,1]),]


    require('RMySQL')
	mydb = dbConnect(MySQL(), user='root', password='O87RlR0lbe', dbname='destinationdb', host='127.0.0.1')
	sql <- paste("SELECT * FROM event_data WHERE experiment_bucket = 'Exposed';", sep = " ", collapse=" ")
	rs <- dbSendQuery(mydb, sql)
	exposed_events_for_destination <- fetch(rs, n=-1)
    close(mydb)
#----------------------------------
# Calculate Control Events for the Destination
#----------------------------------
#control_events_for_destination <- control_data[which(event_data$destination_airport %in% destination_airport_list | ( event_data$hotel_city %in% destination_city_list &  event_data$hotel_state %in% destination_state_list) | event_data$rental_city %in% destination_city_list | event_data$rental_city %in% destination_airport_list | event_data$vacation_airport_destination %in% destination_airport_list),]

    require('RMySQL')
	mydb = dbConnect(MySQL(), user='root', password='O87RlR0lbe', dbname='destinationdb', host='127.0.0.1')
	sql <- paste("SELECT * FROM event_data WHERE experiment_bucket = 'Control';", sep = " ", collapse=" ")
	rs <- dbSendQuery(mydb, sql)
	exposed_events_for_destination <- fetch(rs, n=-1)
    close(mydb)
#----------------------------------
# Calculate Exposed Events for the Destination aggregated by event_num
#----------------------------------
events_for_destination <- sqldf("SELECT distinct(profileid) as profileid, event_date, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date, COUNT(*) as event_num FROM exposed_events_for_destination GROUP BY profileid, event_date, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date")

#----------------------------------
# Count unique searchers from the control bucket
#----------------------------------
control_uu_searches <- count(unique(control_events_for_destination[which(control_events_for_destination$event_type=='FLIGHT_SEARCH' | control_events_for_destination$event_type=='HOTEL_SEARCH' | control_events_for_destination$event_type=='CAR_SEARCH' | control_events_for_destination$event_type=='VACATION_SEARCH'),'profileid'],incomparables=FALSE))
control_uu_searches_sum <- as.data.frame(sum(control_uu_searches$freq))

#----------------------------------
# Count unique searchers from the exposed bucket
#----------------------------------
exposed_uu_searches <- count(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='FLIGHT_SEARCH' | exposed_events_for_destination$event_type=='HOTEL_SEARCH' | exposed_events_for_destination$event_type=='CAR_SEARCH' | exposed_events_for_destination$event_type=='VACATION_SEARCH'),'profileid'],incomparables=FALSE))
exposed_uu_searches_sum <- as.data.frame(sum(exposed_uu_searches$freq))

#----------------------------------
# Count unique travelers from the control bucket
#----------------------------------
#control_confirm_events_for_destination_deduped_ids <- as.data.frame(unique(control_events_for_destination[which(control_events_for_destination$event_type=='FLIGHT_CONFIRMATION' | control_events_for_destination$event_type=='HOTEL_CONFIRMATION' | control_events_for_destination$event_type=='CAR_CONFIRMATION'),'profileid'],incomparables=FALSE))
#colnames(control_confirm_events_for_destination_deduped_ids) <- "profileid"
#control_uu_confirms <- count(control_confirm_events_for_destination_deduped_ids)
#control_uu_confirms_sum <- as.data.frame(sum(control_uu_confirms$freq))

control_confirm_events_for_destination_deduped_ids <- as.data.frame(unique(control_events_for_destination[which(control_events_for_destination$event_type=='FLIGHT_CONFIRMATION' | control_events_for_destination$event_type=='HOTEL_CONFIRMATION' | control_events_for_destination$event_type=='CAR_CONFIRMATION'),'profileid'],incomparables=FALSE))
colnames(control_confirm_events_for_destination_deduped_ids) <- "profileid"
control_deduped_confirmer_events <- merge(x = as.data.frame(control_confirm_events_for_destination_deduped_ids), y = as.data.frame(control_events_for_destination), by.x="profileid", by.y="profileid", all.x=TRUE, all.y=FALSE)
control_deduped_flight_confirmation_events <- subset(control_deduped_confirmer_events, event_type=='FLIGHT_CONFIRMATION')
control_deduped_flight_confirmation_events <- unique(control_deduped_flight_confirmation_events[,-3])
control_deduped_hotel_confirmation_events <- subset(control_deduped_confirmer_events, event_type=='HOTEL_CONFIRMATION')
control_deduped_hotel_confirmation_events <- unique(control_deduped_hotel_confirmation_events[,-3])
control_deduped_car_confirmation_events <- subset(control_deduped_confirmer_events, event_type=='CAR_CONFIRMATION')
control_deduped_car_confirmation_events <- unique(control_deduped_car_confirmation_events[,-3])
control_deduped_confirmation_events <- rbind(control_deduped_flight_confirmation_events, control_deduped_hotel_confirmation_events, control_deduped_car_confirmation_events)
control_deduped_confirmation_events_deduped_ids <- as.data.frame(unique(control_deduped_confirmation_events[which(control_deduped_confirmation_events$event_type=='FLIGHT_CONFIRMATION' | control_deduped_confirmation_events$event_type=='HOTEL_CONFIRMATION' | control_deduped_confirmation_events$event_type=='CAR_CONFIRMATION'),'profileid'],incomparables=FALSE))
control_uu_confirms <- count(control_deduped_confirmation_events_deduped_ids)
control_uu_confirms_sum <- as.data.frame(sum(control_uu_confirms$freq))

#----------------------------------
# Count unique travelers from the exposed bucket
#----------------------------------
confirm_events_for_destination_deduped_ids <- as.data.frame(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='FLIGHT_CONFIRMATION' | exposed_events_for_destination$event_type=='HOTEL_CONFIRMATION' | exposed_events_for_destination$event_type=='CAR_CONFIRMATION'),'profileid'],incomparables=FALSE))
colnames(confirm_events_for_destination_deduped_ids) <- "profileid"
deduped_confirmer_events <- merge(x = as.data.frame(confirm_events_for_destination_deduped_ids), y = as.data.frame(exposed_events_for_destination), by.x="profileid", by.y="profileid", all.x=TRUE, all.y=FALSE)
deduped_flight_confirmation_events <- subset(deduped_confirmer_events, event_type=='FLIGHT_CONFIRMATION')
deduped_flight_confirmation_events <- unique(deduped_flight_confirmation_events[,-3])
deduped_hotel_confirmation_events <- subset(deduped_confirmer_events, event_type=='HOTEL_CONFIRMATION')
deduped_hotel_confirmation_events <- unique(deduped_hotel_confirmation_events[,-3])
deduped_car_confirmation_events <- subset(deduped_confirmer_events, event_type=='CAR_CONFIRMATION')
deduped_car_confirmation_events <- unique(deduped_car_confirmation_events[,-3])
deduped_confirmation_events <- rbind(deduped_flight_confirmation_events, deduped_hotel_confirmation_events, deduped_car_confirmation_events)
deduped_confirmation_events_deduped_ids <- as.data.frame(unique(deduped_confirmation_events[which(deduped_confirmation_events$event_type=='FLIGHT_CONFIRMATION' | deduped_confirmation_events$event_type=='HOTEL_CONFIRMATION' | deduped_confirmation_events$event_type=='CAR_CONFIRMATION'),'profileid'],incomparables=FALSE))
exposed_uu_confirms <- count(deduped_confirmation_events_deduped_ids)
exposed_uu_confirms_sum <- as.data.frame(sum(exposed_uu_confirms$freq))


lift <- data.frame(matrix(ncol = 1, nrow = 1))
lift$control_uu_searches_rate <- (control_uu_searches_sum[,1]/control_uu_count)
lift$control_uu_confirms_rate <- (control_uu_confirms_sum[,1]/control_uu_count)
lift$exposed_uu_searches_rate <- (exposed_uu_searches_sum[,1]/exposed_uu_count)
lift$exposed_uu_confirms_rate <- (exposed_uu_confirms_sum[,1]/exposed_uu_count)

lift$control_uu_searches <- control_uu_searches_sum[,1]
lift$control_uu_confirms <- control_uu_confirms_sum[,1]
lift$exposed_uu_searches <- exposed_uu_searches_sum[,1]
lift$exposed_uu_confirms <- exposed_uu_confirms_sum[,1]

lift$searches_lift_difference <- lift$exposed_uu_searches_rate - lift$control_uu_searches_rate
lift$confirms_lift_difference <- lift$exposed_uu_confirms_rate - lift$control_uu_confirms_rate

unique_users <- c(control_uu_count, exposed_uu_count)
experiment_searches <- c(control_uu_searches_sum[,1], exposed_uu_searches_sum[,1]) 
experiment_confirms <- c(control_uu_confirms_sum[,1], exposed_uu_confirms_sum[,1]) 


#search_results_by_bucket$events_adjusted_difference <- search_results_by_bucket[2,3]-(search_results_by_bucket[1,3]/(uu[1,2]/uu[2,2]))
#confirm_results_by_bucket$uu_adjusted_difference <- confirm_results_by_bucket[2,2]-(confirm_results_by_bucket[1,2]/(uu[1,2]/uu[2,2]))

#----------------------------------
# Events for the destination - includes flight searches, flight confirms, flight boards, hotel searches, hotel confirms, vacation searches, car searches, car confirms, rail searches
#----------------------------------
events_for_destination_by_type.sum <- aggregate(x = events_for_destination$event_num, by = list(events_for_destination$event_type), FUN = "sum")
colnames(events_for_destination_by_type.sum) <- c('event_type','number_of_events')

#----------------------------------
# Confirm Events for the destination by type
#----------------------------------
confirm_events_for_destination_deduped_ids <- as.data.frame(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='FLIGHT_CONFIRMATION' | exposed_events_for_destination$event_type=='HOTEL_CONFIRMATION' | exposed_events_for_destination$event_type=='CAR_CONFIRMATION'),'profileid'],incomparables=FALSE))
colnames(confirm_events_for_destination_deduped_ids) <- "profileid"
deduped_confirmer_events <- merge(x = as.data.frame(confirm_events_for_destination_deduped_ids), y = as.data.frame(exposed_events_for_destination), by.x="profileid", by.y="profileid", all.x=TRUE, all.y=FALSE)
deduped_flight_confirmation_events <- subset(deduped_confirmer_events, event_type=='FLIGHT_CONFIRMATION')
deduped_flight_confirmation_events <- unique(deduped_flight_confirmation_events[,-3])
deduped_hotel_confirmation_events <- subset(deduped_confirmer_events, event_type=='HOTEL_CONFIRMATION')
deduped_hotel_confirmation_events <- unique(deduped_hotel_confirmation_events[,-3])
deduped_car_confirmation_events <- subset(deduped_confirmer_events, event_type=='CAR_CONFIRMATION')
deduped_car_confirmation_events <- unique(deduped_car_confirmation_events[,-3])
deduped_confirmation_events <- rbind(deduped_flight_confirmation_events, deduped_hotel_confirmation_events, deduped_car_confirmation_events)
deduped_confirmation_events <- sqldf("SELECT profileid as profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date, COUNT(*) as event_num FROM deduped_confirmation_events GROUP BY profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date")
confirm_events_for_destination_by_type.sum <- aggregate(x = deduped_confirmation_events$event_num, by = list(deduped_confirmation_events$event_type), FUN = "sum")
colnames(confirm_events_for_destination_by_type.sum) <- c('event_type','number_of_events')

#----------------------------------
# Cost Per Event
#----------------------------------
campaign_cost <- as.numeric(10000.00) 
events_for_destination_by_type.sum$cost_per_event <- round((campaign_cost / as.numeric(events_for_destination_by_type.sum$number_of_events)), digits=2)

#----------------------------------
# Hotel Nights Searched
#----------------------------------
hotel_search_events <- events_for_destination[which( events_for_destination$event_type == 'HOTEL_SEARCH'),]
#hotel_search_events$check_in_date<-as.character(as.Date(hotel_search_events$check_in_date, "%m/%d/%Y"), "%Y%m%d") 
#hotel_search_events$check_out_date<-as.character(as.Date(hotel_search_events$check_out_date, "%m/%d/%Y"), "%Y%m%d") 
hotel_search_events$check_out_date <- ymd(hotel_search_events$check_out_date)
hotel_search_events$check_in_date <- ymd(hotel_search_events$check_in_date)
hotel_search_events$hotel_duration_of_stay <- as.Date(hotel_search_events$check_out_date) - as.Date(hotel_search_events$check_in_date)
hotel_search_events$hotel_nights_searched <- as.numeric(hotel_search_events$event_num) * as.numeric(hotel_search_events$hotel_duration_of_stay)
hotel_nights_searched <- as.data.frame(sum(hotel_search_events$hotel_nights_searched, na.rm = TRUE))
colnames(hotel_nights_searched) <- 'Total Hotel Nights Searched'
#hotel_search_events <- events_for_destination[which( events_for_destination$event_type == 'HOTEL_SEARCH' | events_for_destination$event_type == 'VACATION_SEARCH'),]
#hotel_search_events$check_out_date <- ymd(hotel_search_events$check_out_date)
#hotel_search_events$check_in_date <- ymd(hotel_search_events$check_in_date)
#hotel_search_events$vacation_return_date <- ymd(hotel_search_events$vacation_return_date)
#hotel_search_events$vacation_departure_date <- ymd(hotel_search_events$vacation_departure_date)
#hotel_search_events$hotel_duration_of_stay <- sapply(hotel_search_events$event_type, function(x) {
#    if (x == 'HOTEL_SEARCH') {
#        return(hotel_search_events$check_out_date - hotel_search_events$check_in_date)
#    }
#    else  {
#        return(hotel_search_events$vacation_return_date - hotel_search_events$vacation_departure_date)
#    }
#})
#hotel_search_events[hotel_search_events$hotel_duration_of_stay == 'NA','hotel_duration_of_stay'] <- 1
#hotel_search_events$hotel_duration_of_stay <- as.Date(hotel_search_events$check_out_date) - as.Date(hotel_search_events$check_in_date)
#hotel_search_events$hotel_nights_searched <- as.numeric(hotel_search_events$event_num) * as.numeric(hotel_search_events$hotel_duration_of_stay)
#hotel_nights_searched <- as.data.frame(sum(hotel_search_events$hotel_nights_searched, na.rm = TRUE))
#colnames(hotel_nights_searched) <- 'Total Hotel Nights Searched'

#----------------------------------
# Hotel Rooms Searched
#----------------------------------
hotel_search_events$total_rooms <- as.numeric(hotel_search_events$event_num) * as.numeric(hotel_search_events$number_of_rooms)
total_rooms_searched <- as.data.frame(sum(hotel_search_events$total_rooms, na.rm=TRUE))
colnames(total_rooms_searched) <- 'Total Rooms Searched'

#----------------------------------
# Top Flight Search City Originations
#----------------------------------
search_events_for_destination <- events_for_destination[ which(events_for_destination$event_type=='FLIGHT_SEARCH'), ]
flight_search_orig_markets <- aggregate(x = search_events_for_destination$event_num, by = list(search_events_for_destination$origin_airport), FUN = "sum")
colnames(flight_search_orig_markets) <- c("origin_airport", "count")
flight_search_orig_markets <- flight_search_orig_markets[ which(nchar(as.character(flight_search_orig_markets$origin_airport))==3), ]
flight_search_orig_markets <- merge(x = as.data.frame(flight_search_orig_markets), y = as.data.frame(airports), by.x="origin_airport", by.y="iata", all.x=TRUE, all.y=FALSE)
flight_search_orig_markets <- aggregate(x = flight_search_orig_markets$count, by = list(flight_search_orig_markets$city, flight_search_orig_markets$state), FUN = "sum")
colnames(flight_search_orig_markets) <- c("origin_city", "origin_state", "count_searches")
flight_search_orig_markets <- flight_search_orig_markets[order(-(as.numeric(as.character(flight_search_orig_markets[,3])))),]

#----------------------------------
# Top Flight Confirm City Originations
#----------------------------------
flight_confirm_events_for_destination_deduped_ids <- as.data.frame(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='FLIGHT_CONFIRMATION'),'profileid'],incomparables=FALSE))
colnames(flight_confirm_events_for_destination_deduped_ids) <- "profileid"
deduped_flight_confirmer_events <- merge(x = as.data.frame(flight_confirm_events_for_destination_deduped_ids), y = as.data.frame(exposed_events_for_destination), by.x="profileid", by.y="profileid", all.x=TRUE, all.y=FALSE)
deduped_flight_confirmation_events <- subset(deduped_flight_confirmer_events, event_type=='FLIGHT_CONFIRMATION')
deduped_flight_confirmation_events <- unique(deduped_flight_confirmation_events[,-3])
deduped_flight_confirmation_events <- sqldf("SELECT profileid as profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date, COUNT(*) as event_num FROM deduped_flight_confirmation_events GROUP BY profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date")
flight_confirm_orig_markets <- aggregate(x = deduped_flight_confirmation_events$event_num, by = list(deduped_flight_confirmation_events$origin_airport), FUN = "sum")
colnames(flight_confirm_orig_markets) <- c("origin_airport", "count")
flight_confirm_orig_markets <- flight_confirm_orig_markets[ which(nchar(as.character(flight_confirm_orig_markets$origin_airport))==3), ]
flight_confirm_orig_markets <- merge(x = as.data.frame(flight_confirm_orig_markets), y = as.data.frame(airports), by.x="origin_airport", by.y="iata", all.x=TRUE, all.y=FALSE)
flight_confirm_orig_markets <- aggregate(x = flight_confirm_orig_markets$count, by = list(flight_confirm_orig_markets$city, flight_confirm_orig_markets$state), FUN = "sum")
colnames(flight_confirm_orig_markets) <- c("origin_city", "origin_state", "count_confirms")
flight_confirm_orig_markets <- flight_confirm_orig_markets[order(-(as.numeric(as.character(flight_confirm_orig_markets[,3])))),]

#----------------------------------
# Hotel Confirmer Events
#----------------------------------
hotel_confirm_events_for_destination_deduped_ids <- as.data.frame(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='HOTEL_CONFIRMATION'),'profileid'],incomparables=FALSE))
colnames(hotel_confirm_events_for_destination_deduped_ids) <- "profileid"
deduped_hotel_confirmer_events <- merge(x = as.data.frame(hotel_confirm_events_for_destination_deduped_ids), y = as.data.frame(exposed_events_for_destination), by.x="profileid", by.y="profileid", all.x=TRUE, all.y=FALSE)

#----------------------------------
# Hotel Nights Confirmed
#----------------------------------
if (nrow(subset(deduped_hotel_confirmer_events, event_type=='HOTEL_CONFIRMATION'))>0) {
hotel_confirm_events_for_destination_deduped <- subset(deduped_hotel_confirmer_events, event_type=='HOTEL_CONFIRMATION')
hotel_confirm_events_for_destination_deduped <- unique(hotel_confirm_events_for_destination_deduped[,-3])
hotel_confirm_events_for_destination_deduped <- sqldf("SELECT profileid as profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date, COUNT(*) as event_num FROM hotel_confirm_events_for_destination_deduped GROUP BY profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date")
hotel_confirm_events_for_destination_deduped$check_out_date <- ymd(hotel_confirm_events_for_destination_deduped$check_out_date)
hotel_confirm_events_for_destination_deduped$check_in_date <- ymd(hotel_confirm_events_for_destination_deduped$check_in_date)
hotel_confirm_events_cleaned <- hotel_confirm_events_for_destination_deduped[which(hotel_confirm_events_for_destination_deduped$check_in_date!='' & hotel_confirm_events_for_destination_deduped$check_out_date!=''),]
for (i in 1:length(hotel_confirm_events_cleaned) ) {
hotel_confirm_events_cleaned$hotel_duration_of_stay <- as.Date(hotel_confirm_events_cleaned$check_out_date) - as.Date(hotel_confirm_events_cleaned$check_in_date)
}
#hotel_confirm_events_cleaned$hotel_duration_of_stay <- as.Date(ymd(hotel_confirm_events_cleaned$check_out_date)) - as.Date(ymd(hotel_confirm_events_cleaned$check_in_date))
hotel_confirm_events_cleaned$hotel_nights_confirmed <- as.numeric(hotel_confirm_events_cleaned$event_num) * as.numeric(hotel_confirm_events_cleaned$hotel_duration_of_stay)
hotel_nights_confirmed <- as.data.frame(sum(hotel_confirm_events_cleaned$hotel_nights_confirmed, na.rm = TRUE))
colnames(hotel_nights_confirmed) <- 'Total Hotel Nights Confirmed'
}else {
hotel_nights_confirmed <- data.frame(matrix(ncol = 1, nrow = 1))
hotel_nights_confirmed[1,1] <- 0
colnames(hotel_nights_confirmed) <- 'Total Hotel Nights Confirmed'
}

#----------------------------------
# Hotel Rooms Booked
#----------------------------------
if (nrow(subset(deduped_hotel_confirmer_events, event_type=='HOTEL_CONFIRMATION'))>0) {
hotel_confirm_events_for_destination_deduped <- subset(deduped_hotel_confirmer_events, event_type=='HOTEL_CONFIRMATION')
hotel_confirm_events_for_destination_deduped <- unique(hotel_confirm_events_for_destination_deduped[,-3])
hotel_confirm_events_for_destination_deduped <- sqldf("SELECT profileid as profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date, COUNT(*) as event_num FROM hotel_confirm_events_for_destination_deduped GROUP BY profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date")
hotel_confirm_events_for_destination_deduped$total_rooms <- as.numeric(hotel_confirm_events_for_destination_deduped$event_num) * as.numeric(hotel_confirm_events_for_destination_deduped$number_of_rooms)
total_rooms_booked <- as.data.frame(sum(hotel_confirm_events_for_destination_deduped$total_rooms, na.rm=TRUE))
colnames(total_rooms_booked) <- 'Total Rooms Booked'
}else {
total_rooms_booked <- data.frame(matrix(ncol = 1, nrow = 1))
total_rooms_booked[1,1] <- 0
colnames(total_rooms_booked) <- 'Total Rooms Booked'
}

#----------------------------------
# Flight Confirmer Events
#----------------------------------
flight_confirm_events_for_destination_deduped_ids <- as.data.frame(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='FLIGHT_CONFIRMATION'),'profileid'],incomparables=FALSE))
colnames(flight_confirm_events_for_destination_deduped_ids) <- "profileid"
deduped_flight_confirmer_events <- merge(x = as.data.frame(flight_confirm_events_for_destination_deduped_ids), y = as.data.frame(exposed_events_for_destination), by.x="profileid", by.y="profileid", all.x=TRUE, all.y=FALSE)

#----------------------------------
# Confirmed Travelers
#----------------------------------
deduped_flight_confirmation_events <- subset(deduped_flight_confirmer_events, event_type=='FLIGHT_CONFIRMATION')
deduped_flight_confirmation_events <- unique(deduped_flight_confirmation_events[,-3])
deduped_flight_confirmation_events <- sqldf("SELECT profileid as profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date, COUNT(*) as event_num FROM deduped_flight_confirmation_events GROUP BY profileid, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date")
deduped_flight_confirmation_events$total_travelers <- as.numeric(as.character(deduped_flight_confirmation_events$event_num)) * as.numeric(as.character(deduped_flight_confirmation_events$number_of_travelers))
deduped_flight_confirmation_events$total_travelers[is.na(deduped_flight_confirmation_events$total_travelers)] <- 1
total_confirmed_travelers <- as.data.frame(sum(deduped_flight_confirmation_events$total_travelers, na.rm = TRUE))
colnames(total_confirmed_travelers) <- 'Total Confirmed Travelers'
paste('writing results')
#----------------------------------
# Write results to file
#----------------------------------
write.csv(lift[,-1], file = ".lift_results.csv", row.names=FALSE)
write.csv(total_confirmed_travelers, file = ".total_confirmed_travelers.csv", row.names=FALSE)
write.csv(flight_confirm_orig_markets, file = ".flight_confirm_orig_markets.csv", row.names=FALSE)
write.csv(flight_search_orig_markets, file = ".flight_search_orig_markets.csv", row.names=FALSE)
write.csv(hotel_nights_confirmed, file = ".hotel_nights_confirmed.csv", row.names=FALSE)
write.csv(hotel_nights_searched, file = ".hotel_nights_searched.csv", row.names=FALSE)
write.csv(total_rooms_booked, file = ".hotel_rooms_confirmed.csv", row.names=FALSE)
write.csv(total_rooms_searched, file = ".hotel_rooms_searched.csv", row.names=FALSE)
write.csv(events_for_destination_by_type.sum, file = ".events_for_destination_by_type.csv", row.names=FALSE)

cal <- function(dt) {
    # Reads a date object and returns a tuple (weekrow, daycol)
    # where weekrow starts at 1 and daycol starts at 1 for Sunday
    year <- year(dt)
    month <- month(dt)
    day <- day(dt)
    wday_first <- wday(ymd(paste(year, month, 1, sep = '-'), quiet = TRUE))
    offset <- 7 + (wday_first - 2)
    weekrow <- ((day + offset) %/% 7) - 1
    daycol <- (day + offset) %% 7

    c(weekrow, daycol)
}
weekrow <- function(dt) {
    cal(dt)[1]
}
daycol <- function(dt) {
    cal(dt)[2]
}
vweekrow <- function(dts) {
    sapply(dts, weekrow)
}
vdaycol <- function(dts) {
    sapply(dts, daycol)
}

#----------------------------------
# Confirm Heatmap Calendar by Event Date
#----------------------------------
confirm_events_for_destination <- subset(events_for_destination, event_type=='FLIGHT_CONFIRMATION')
DestinationCore_confirms_cal <- aggregate(x = as.numeric(as.character(confirm_events_for_destination$event_num)), by = list(ymd(confirm_events_for_destination$event_date)), FUN = "sum")
colnames(DestinationCore_confirms_cal)<-c("event_date", "X_c10")
DestinationCore_confirms_cal$event_date <- as.Date(DestinationCore_confirms_cal$event_date)
dailymean <- mean(DestinationCore_confirms_cal[,'X_c10'], na.rm=TRUE)
DestinationCore_confirms_cal$events_anomaly <- DestinationCore_confirms_cal$X_c10 - dailymean
DestinationCore_confirms_cal$month <- month(DestinationCore_confirms_cal$event_date, label = TRUE, abbr = TRUE)
DestinationCore_confirms_cal$year <- year(DestinationCore_confirms_cal$event_date)
DestinationCore_confirms_cal$weekrow <- factor(vweekrow(DestinationCore_confirms_cal$event_date), levels = c(5, 4, 3, 2, 1, 0), labels = c('6', '5', '4', '3', '2', '1'))
DestinationCore_confirms_cal$daycol <- factor(vdaycol(DestinationCore_confirms_cal$event_date), labels = c('u', 'm', 't', 'w', 'r', 'f', 's'))
DestinationCore_confirms_cal$day <- day(DestinationCore_confirms_cal$event_date)

png(".confirm_heatmap.png", width= 1000)
print(
ggplot(data = subset(DestinationCore_confirms_cal, year > max(DestinationCore_confirms_cal$year) - 11),
        aes(x = daycol, y = weekrow, fill = events_anomaly)) +
     theme_bw() +
     theme(axis.text.x = element_blank(),
           axis.text.y = element_blank(),
           panel.grid.major = element_blank(),
           panel.grid.minor = element_blank(),
           axis.ticks.x = element_blank(),
           axis.ticks.y = element_blank(),
           axis.title.x = element_blank(),
           axis.title.y = element_blank(),
           legend.position = "bottom",
           legend.key.width = unit(1, "in"),
           legend.margin = unit(0, "in")) +
     geom_tile(colour = "white") +
     geom_text(aes(label=day, size=3)) +
     facet_grid(year ~ month) +
     scale_fill_gradientn(colours = c("#D61818","#FFFFBD","#B5E384")) +
     ggtitle("Difference between Daily Confirms and Mean Daily Confirms by Event Date")
	 )
dev.off()

#----------------------------------
# Search Heatmap Calendar by Event Date
#----------------------------------

DestinationCore_searches_cal <- aggregate(x = as.numeric(as.character(search_events_for_destination$event_num)), by = list(ymd(search_events_for_destination$event_date)), FUN = "sum")
colnames(DestinationCore_searches_cal)<-c("event_date", "X_c10")
DestinationCore_searches_cal$event_date <- as.Date(DestinationCore_searches_cal$event_date)
dailymean <- mean(DestinationCore_searches_cal[,'X_c10'], na.rm=TRUE)
DestinationCore_searches_cal$events_anomaly <- DestinationCore_searches_cal$X_c10 - dailymean
DestinationCore_searches_cal$month <- month(DestinationCore_searches_cal$event_date, label = TRUE, abbr = TRUE)
DestinationCore_searches_cal$year <- year(DestinationCore_searches_cal$event_date)
DestinationCore_searches_cal$weekrow <- factor(vweekrow(DestinationCore_searches_cal$event_date), levels = c(5, 4, 3, 2, 1, 0), labels = c('6', '5', '4', '3', '2', '1'))
DestinationCore_searches_cal$daycol <- factor(vdaycol(DestinationCore_searches_cal$event_date), labels = c('u', 'm', 't', 'w', 'r', 'f', 's'))
DestinationCore_searches_cal$day <- day(DestinationCore_searches_cal$event_date)

png(".search_heatmap.png", width= 1000)
print(
ggplot(data = subset(DestinationCore_searches_cal, year > max(DestinationCore_searches_cal$year) - 11),
        aes(x = daycol, y = weekrow, fill = events_anomaly)) +
     theme_bw() +
     theme(axis.text.x = element_blank(),
           axis.text.y = element_blank(),
           panel.grid.major = element_blank(),
           panel.grid.minor = element_blank(),
           axis.ticks.x = element_blank(),
           axis.ticks.y = element_blank(),
           axis.title.x = element_blank(),
           axis.title.y = element_blank(),
           legend.position = "bottom",
           legend.key.width = unit(1, "in"),
           legend.margin = unit(0, "in")) +
     geom_tile(colour = "white") +
     geom_text(aes(label=day, size=3)) +
     facet_grid(year ~ month) +
     scale_fill_gradientn(colours = c("#D61818","#FFFFBD","#B5E384")) +
     ggtitle("Difference between Daily Searches and Mean Daily Searches by Event Date")
	 )
dev.off()

#----------------------------------
# Confirm Heatmap Calendar by Departure Date
#----------------------------------

DestinationCore_confirms_cal <- aggregate(x = as.numeric(as.character(confirm_events_for_destination$event_num)), by = list(ymd(confirm_events_for_destination$departure_date)), FUN = "sum")
colnames(DestinationCore_confirms_cal)<-c("departure_date", "X_c10")
DestinationCore_confirms_cal$departure_date <- as.Date(DestinationCore_confirms_cal$departure_date)
dailymean <- mean(DestinationCore_confirms_cal[,'X_c10'], na.rm=TRUE)
DestinationCore_confirms_cal$events_anomaly <- DestinationCore_confirms_cal$X_c10 - dailymean
DestinationCore_confirms_cal$month <- month(DestinationCore_confirms_cal$departure_date, label = TRUE, abbr = TRUE)
DestinationCore_confirms_cal$year <- year(DestinationCore_confirms_cal$departure_date)
DestinationCore_confirms_cal$weekrow <- factor(vweekrow(DestinationCore_confirms_cal$departure_date), levels = c(5, 4, 3, 2, 1, 0), labels = c('6', '5', '4', '3', '2', '1'))
DestinationCore_confirms_cal$daycol <- factor(vdaycol(DestinationCore_confirms_cal$departure_date), labels = c('u', 'm', 't', 'w', 'r', 'f', 's'))
DestinationCore_confirms_cal$day <- day(DestinationCore_confirms_cal$departure_date)

png(".confirm_departure_heatmap.png", width= 1200)
print(
    ggplot(data = subset(DestinationCore_confirms_cal, year > max(DestinationCore_confirms_cal$year) - 11),
           aes(x = daycol, y = weekrow, fill = events_anomaly)) +
        theme_bw() +
        theme(axis.text.x = element_blank(),
              axis.text.y = element_blank(),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank(),
              legend.position = "bottom",
              legend.key.width = unit(1, "in"),
              legend.margin = unit(0, "in")) +
        geom_tile(colour = "white") +
        geom_text(aes(label=day, size=2)) +
        facet_grid(year ~ month) +
        scale_fill_gradientn(colours = c("#D61818","#FFFFBD","#B5E384")) +
        ggtitle("Difference between Daily Confirms and Mean Daily Confirms by Departure Date")
)
dev.off()

#----------------------------------
# Search Heatmap Calendar by Departure Date
#----------------------------------

DestinationCore_search_departures_cal <- aggregate(x = as.numeric(as.character(search_events_for_destination$event_num)), by = list(ymd(search_events_for_destination$departure_date)), FUN = "sum")
colnames(DestinationCore_search_departures_cal)<-c("departure_date", "X_c10")
DestinationCore_search_departures_cal$departure_date <- as.Date(DestinationCore_search_departures_cal$departure_date)
dailymean <- mean(DestinationCore_search_departures_cal[,'X_c10'], na.rm=TRUE)
DestinationCore_search_departures_cal$events_anomaly <- DestinationCore_search_departures_cal$X_c10 - dailymean
DestinationCore_search_departures_cal$month <- month(DestinationCore_search_departures_cal$departure_date, label = TRUE, abbr = TRUE)
DestinationCore_search_departures_cal$year <- year(DestinationCore_search_departures_cal$departure_date)
DestinationCore_search_departures_cal$weekrow <- factor(vweekrow(DestinationCore_search_departures_cal$departure_date), levels = c(5, 4, 3, 2, 1, 0), labels = c('6', '5', '4', '3', '2', '1'))
DestinationCore_search_departures_cal$daycol <- factor(vdaycol(DestinationCore_search_departures_cal$departure_date), labels = c('u', 'm', 't', 'w', 'r', 'f', 's'))
DestinationCore_search_departures_cal$day <- day(DestinationCore_search_departures_cal$departure_date)

png(".search_departure_heatmap.png", width= 1200)
print(
    ggplot(data = subset(DestinationCore_search_departures_cal, year > max(DestinationCore_search_departures_cal$year) - 11),
           aes(x = daycol, y = weekrow, fill = events_anomaly)) +
        theme_bw() +
        theme(axis.text.x = element_blank(),
              axis.text.y = element_blank(),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank(),
              legend.position = "bottom",
              legend.key.width = unit(1, "in"),
              legend.margin = unit(0, "in")) +
        geom_tile(colour = "white") +
        geom_text(aes(label=day, size=3)) +
        facet_grid(year ~ month) +
        scale_fill_gradientn(colours = c("#D61818","#FFFFBD","#B5E384")) +
        ggtitle("Difference between Daily Searches and Mean Daily Searches by Departure Date")
)
dev.off()
}