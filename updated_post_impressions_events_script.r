require('lubridate')
require('sqldf')
require('ggplot2')
require('plyr')
require('timeDate')
require('grid')


#----------------------------------
# Load the event data
#----------------------------------
load_destination_data <- function(x){
	sqldf("attach 'destinationdb.sqlite' as new")

	sqldf("create table event_data(experiment_bucket TEXT, profileid, event_date TEXT, event_type TEXT, partner TEXT, origin_airport TEXT, destination_airport TEXT, departure_date TEXT, return_date TEXT, number_of_travelers INTEGER, hotel_city TEXT, hotel_state TEXT, hotel_country TEXT, check_in_date TEXT, check_out_date TEXT, number_of_rooms INTEGER, rental_city TEXT, rental_dropoff_city TEXT, rental_pickup_date TEXT, rental_dropoff_date TEXT, vacation_airport_origin TEXT, vacation_airport_destination TEXT, vacation_departure_date TEXT, vacation_return_date TEXT)", dbname = "destinationdb.sqlite")

	read.csv.sql(x, header = TRUE, sep = ",", filter = list('gawk -f prog', prog = '{ gsub(/"/, ""); print }'), row.names=FALSE, comment.char = "", eol="\n", sql = "replace into event_data select * from file", dbname = "destinationdb.sqlite")
}

#----------------------------------
# Load the uu counts
#----------------------------------
load_exposed_uu_counts <- function(x){
	uu_count <- as.data.frame(read.csv(x, header = TRUE, sep = ",", quote = "\""))
	exposed_uu_count <- as.data.frame(as.numeric(as.character(uu_count[1,2])))
	return(exposed_uu_count)
}
load_control_uu_counts <- function(x){
	uu_count <- as.data.frame(read.csv(x, header = TRUE, sep = ",", quote = "\""))
	control_uu_count <- as.data.frame(as.numeric(as.character(uu_count[2,2])))
	return(control_uu_count)
}

#----------------------------------
# List of All Airports
#----------------------------------
load_airport_data <- function(x){
	airports <- read.csv("./data/airports.csv", header=F)
	colnames(airports) <- c("icao", "iata", "airport_name", "city", "state", "country")
	return(airports)
}

#----------------------------------
# Load Airport Travel Data
#----------------------------------


#----------------------------------
# Calculate Exposed Events for the Destination
#----------------------------------
exposed_events_for_destination <- function(x){
	exposed_events_for_destination <- sqldf("SELECT * FROM event_data WHERE experiment_bucket = 'Exposed'", dbname = "destinationdb.sqlite")
	return(exposed_events_for_destination)
}

#----------------------------------
# Calculate Control Events for the Destination
#----------------------------------
control_events_for_destination <- function(x){
	control_events_for_destination <- sqldf("SELECT * FROM event_data WHERE experiment_bucket = 'Control'", dbname = "destinationdb.sqlite")
	return(control_events_for_destination)
}

#----------------------------------
# Calculate Exposed Events for the Destination aggregated by event_num
#----------------------------------
events_for_destination <- function(x){
	events_for_destination <- sqldf("SELECT distinct(profileid) as profileid, event_date, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date, COUNT(*) as event_num FROM exposed_events_for_destination GROUP BY profileid, event_date, event_type, partner, origin_airport, destination_airport, departure_date, return_date, number_of_travelers, hotel_city, hotel_state, hotel_country, check_in_date, check_out_date, number_of_rooms, rental_city, rental_dropoff_city, rental_pickup_date, rental_dropoff_date, vacation_airport_origin, vacation_airport_destination, vacation_departure_date, vacation_return_date")
	return(events_for_destination)
}

#----------------------------------
# Count unique searchers from the control bucket
#----------------------------------
control_uu_searches_sum <- function(x){
	exposed_uu_searches <- count(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='FLIGHT_SEARCH' | exposed_events_for_destination$event_type=='HOTEL_SEARCH' | exposed_events_for_destination$event_type=='CAR_SEARCH' | exposed_events_for_destination$event_type=='VACATION_SEARCH'),'profileid'],incomparables=FALSE))
    exposed_uu_searches_sum <- as.data.frame(sum(exposed_uu_searches$freq))
	return(control_uu_searches_sum)
}

#----------------------------------
# Count unique travelers from the exposed bucket
#----------------------------------
exposed_uu_searches_sum <- function(x){
	exposed_uu_searches <- count(unique(exposed_events_for_destination[which(exposed_events_for_destination$event_type=='FLIGHT_SEARCH' | exposed_events_for_destination$event_type=='HOTEL_SEARCH' | exposed_events_for_destination$event_type=='CAR_SEARCH' | exposed_events_for_destination$event_type=='VACATION_SEARCH'),'profileid'],incomparables=FALSE))
    exposed_uu_searches_sum <- as.data.frame(sum(exposed_uu_searches$freq))
	return(exposed_uu_searches_sum)
}

#----------------------------------
# Count unique travelers from the control bucket
#----------------------------------
control_uu_confirms_sum <- function(x){
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
	return(control_uu_confirms_sum)
}

#----------------------------------
# Count unique travelers from the exposed bucket
#----------------------------------
exposed_uu_confirms_sum <- function(x){
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
	return(exposed_uu_confirms_sum)
}






