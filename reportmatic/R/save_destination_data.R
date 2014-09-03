#' A function to check if the file is a csv and if it is to upload it to a sqlite database for safekeeping.
#'
#' This function allows you to save the data into a sqlite database.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' save_destination_data()
save_destination_data <- function(file, ...){

require('lubridate')
require('sqldf')
require('ggplot2')
require('plyr')
require('timeDate')
require('grid')

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

    require('RMySQL')
	mydb = dbConnect(MySQL(), user='root', password='O87RlR0lbe', dbname='destinationdb', host='127.0.0.1')
	sql <- paste("SELECT * FROM event_data WHERE experiment_bucket = 'Exposed';", sep = " ", collapse=" ")
	rs <- dbSendQuery(mydb, sql)
	exposed_events_for_destination <- fetch(rs, n=-1)
#----------------------------------
# Calculate Control Events for the Destination
#----------------------------------

	sql2 <- paste("SELECT * FROM event_data WHERE experiment_bucket = 'Control';", sep = " ", collapse=" ")
	rs2 <- dbSendQuery(mydb, sql2)
	control_events_for_destination <- fetch(rs2, n=-1)
	all_cons <- dbListConnections(MySQL())
	for(con in all_cons) 
      dbDisconnect(con) 
 
#----------------------------------
# Calculate Exposed Events for the Destination aggregated by event_num
#----------------------------------
events_for_destination <- count(exposed_events_for_destination, c('profileid', 'event_date', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date'))
colnames(events_for_destination) <- c('profileid', 'event_date', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date', 'event_num')

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
deduped_confirmation_events <- count(deduped_confirmation_events, c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date'))
colnames(deduped_confirmation_events) <- c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date', 'event_num')
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
hotel_search_events <- subset(events_for_destination, events_for_destination$event_type == 'HOTEL_SEARCH' & events_for_destination$check_in_date!="" & events_for_destination$check_out_date!="" & check_in_date!='NaN-NaN-NaN' & check_out_date!='NaN-NaN-NaN' & check_in_date!='mm/dd/yy' & check_out_date!='mm/dd/yy')
hotel_search_events$check_out_date <- ymd(hotel_search_events$check_out_date)
hotel_search_events$check_in_date <- ymd(hotel_search_events$check_in_date)
hotel_search_events$hotel_duration_of_stay <- hotel_search_events$check_out_date - hotel_search_events$check_in_date
hotel_search_events$hotel_nights_searched <- as.numeric(hotel_search_events$event_num) * as.numeric(hotel_search_events$hotel_duration_of_stay)
hotel_nights_searched <- as.data.frame(sum(hotel_search_events$hotel_nights_searched, na.rm = TRUE))
colnames(hotel_nights_searched) <- 'Total Hotel Nights Searched'

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
deduped_flight_confirmation_events <- count(deduped_flight_confirmation_events, c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date'))
colnames(deduped_flight_confirmation_events) <- c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date', 'event_num')
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
hotel_confirm_events_for_destination_deduped <- subset(deduped_hotel_confirmer_events, event_type=='HOTEL_CONFIRMATION' & check_in_date!="" & check_out_date!="" & check_in_date!='NaN-NaN-NaN' & check_out_date!='NaN-NaN-NaN' & check_in_date!='mm/dd/yy' & check_out_date!='mm/dd/yy')
hotel_confirm_events_for_destination_deduped$check_out_date <- ymd(hotel_confirm_events_for_destination_deduped$check_out_date)
hotel_confirm_events_for_destination_deduped$check_in_date <- ymd(hotel_confirm_events_for_destination_deduped$check_in_date)
hotel_confirm_events_cleaned <- hotel_confirm_events_for_destination_deduped[which(hotel_confirm_events_for_destination_deduped$check_in_date!='' & hotel_confirm_events_for_destination_deduped$check_out_date!=''),]
hotel_confirm_events_cleaned$hotel_duration_of_stay <- hotel_confirm_events_cleaned$check_out_date - hotel_confirm_events_cleaned$check_in_date
hotel_confirm_events_cleaned$hotel_nights_confirmed <- as.numeric(as.character(hotel_confirm_events_cleaned$event_num)) * as.numeric(as.character(hotel_confirm_events_cleaned$hotel_duration_of_stay))
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
hotel_confirm_events_for_destination_deduped <- count(hotel_confirm_events_for_destination_deduped, c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date'))
colnames(hotel_confirm_events_for_destination_deduped) <- c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date', 'event_num')
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
deduped_flight_confirmation_events <- count(deduped_flight_confirmation_events, c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date'))
colnames(deduped_flight_confirmation_events) <- c('profileid', 'event_type', 'partner', 'origin_airport', 'destination_airport', 'departure_date', 'return_date', 'number_of_travelers', 'hotel_city', 'hotel_state', 'hotel_country', 'check_in_date', 'check_out_date', 'number_of_rooms', 'rental_city', 'rental_dropoff_city', 'rental_pickup_date', 'rental_dropoff_date', 'vacation_airport_origin', 'vacation_airport_destination', 'vacation_departure_date', 'vacation_return_date', 'event_num')
deduped_flight_confirmation_events$total_travelers <- as.numeric(as.character(deduped_flight_confirmation_events$event_num)) * as.numeric(as.character(deduped_flight_confirmation_events$number_of_travelers))
deduped_flight_confirmation_events$total_travelers[is.na(deduped_flight_confirmation_events$total_travelers)] <- 1
total_confirmed_travelers <- as.data.frame(sum(deduped_flight_confirmation_events$total_travelers, na.rm = TRUE))
colnames(total_confirmed_travelers) <- 'Total Confirmed Travelers'
paste('writing results')
#----------------------------------
# Write results to file
#----------------------------------
write.csv(lift[,-1], file = "lift_results.csv", row.names=FALSE)
write.csv(total_confirmed_travelers, file = "total_confirmed_travelers.csv", row.names=FALSE)
write.csv(flight_confirm_orig_markets, file = "flight_confirm_orig_markets.csv", row.names=FALSE)
write.csv(flight_search_orig_markets, file = "flight_search_orig_markets.csv", row.names=FALSE)
write.csv(hotel_nights_confirmed, file = "hotel_nights_confirmed.csv", row.names=FALSE)
write.csv(hotel_nights_searched, file = "hotel_nights_searched.csv", row.names=FALSE)
write.csv(total_rooms_booked, file = "hotel_rooms_confirmed.csv", row.names=FALSE)
write.csv(total_rooms_searched, file = "hotel_rooms_searched.csv", row.names=FALSE)
write.csv(events_for_destination_by_type.sum, file = "events_for_destination_by_type.csv", row.names=FALSE)

}