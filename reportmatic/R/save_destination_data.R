#' A function to check if the file is a csv and if it is to upload it to a sqlite database for safekeeping.
#'
#' This function allows you to save the data into a sqlite database.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' save_destination_data()
save_destination_data <- function(file){
	uu_count <- as.data.frame(read.csv(file, header = TRUE, sep = ",", quote = "\""))
	exposed_uu_count <- as.data.frame(as.numeric(as.character(uu_count[1,2])))
}