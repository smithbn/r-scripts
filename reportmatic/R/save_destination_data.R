#' A function to check if the file is a csv and if it is to upload it to a sqlite database for safekeeping.
#'
#' This function allows you to save the data into a sqlite database.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' save_destination_data()
save_destination_data <- function(file, ...){
  if(!grepl(".csv$", file)){
    stop("Uploaded file must be a .csv file!")
  }
    require('sqldf')
	
	sqldf("attach '/home/bsmith/databases/destinationdb.sqlite' as new")

	sqldf("create table event_data(experiment_bucket TEXT, profileid, event_date TEXT, event_type TEXT, partner TEXT, origin_airport TEXT, destination_airport TEXT, departure_date TEXT, return_date TEXT, number_of_travelers INTEGER, hotel_city TEXT, hotel_state TEXT, hotel_country TEXT, check_in_date TEXT, check_out_date TEXT, number_of_rooms INTEGER, rental_city TEXT, rental_dropoff_city TEXT, rental_pickup_date TEXT, rental_dropoff_date TEXT, vacation_airport_origin TEXT, vacation_airport_destination TEXT, vacation_departure_date TEXT, vacation_return_date TEXT)", dbname = "/home/bsmith/databases/destinationdb.sqlite")

	read.csv.sql(file, header = TRUE, sep = ",", filter = list('gawk -f prog', prog = '{ gsub(/"/, ""); print }'), row.names=FALSE, comment.char = "", eol="\n", sql = "replace into event_data select * from file", dbname = "/home/bsmith/databases/destinationdb.sqlite")
}