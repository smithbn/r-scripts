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
    require('RMySQL')
	mydb = dbConnect(MySQL(), user='root', password='O87RlR0lbe', dbname='destinationdb', host='127.0.0.1')
	rs = dbSendQuery(mydb, "select * from event_data")
	data = fetch(rs, n=-1)
	invisible()
}