# Save results to csv
# --------------------------------------------------------------------
write.table(duration_of_stay_results, file = "./data/length_of_stay.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(hotel_room_nights_results, file = "./data/number_of_hotel_room_nights.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(events_by_type_results, file = "./data/events_by_type.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(event_to_travel_results, file = "./data/event_to_travel.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(number_in_party_results, file = "./data/number_in_party.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(number_of_travelers_results, file = "./data/number_of_travelers.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(search_confirm_originations_results, file = "./data/search_confirm_originations.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(searches_by_departure_date_results, file = "./data/searches_by_departure_date.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(confirms_by_departure_date_results, file = "./data/confirms_by_departure_date.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(post_impression_beacon_events_results, file = "./data/post_impression_beacon_fires.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)
write.table(unique_travelers_results, file = "./data/unique_travelers.csv", sep=",", col.names = FALSE, row.names = FALSE, quote = TRUE)