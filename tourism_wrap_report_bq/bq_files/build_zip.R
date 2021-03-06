insertion_order_id_name <- as.integer(strsplit(as.character(insertion_order_id), ",")[[1]][1])
zip(zipfile = paste0("Tourism Wrap Report Data - ",advertiser_name," - ",insertion_order_id_name,".zip"), files = "data", zip = Sys.getenv("R_ZIPCMD", "zip"))
file.copy(paste0("Tourism Wrap Report Data - ",advertiser_name," - ",insertion_order_id_name,".zip"), "~/Google Drive/tourism_wrap_reports/queue", overwrite = TRUE, recursive = TRUE, copy.mode = TRUE, copy.date = TRUE)
file.remove(paste0("Tourism Wrap Report Data - ",advertiser_name," - ",insertion_order_id_name,".zip"))
file.remove(c("./data/length_of_stay.csv","./data/number_of_hotel_room_nights.csv","./data/events_by_type.csv","./data/event_to_travel.csv","./data/number_in_party.csv","./data/number_of_travelers.csv","./data/search_confirm_originations.csv","./data/searches_by_departure_date.csv","./data/confirms_by_departure_date.csv","./data/post_impression_beacon_fires.csv","./data/unique_travelers.csv"))
