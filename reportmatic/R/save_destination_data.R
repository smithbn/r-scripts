#' A function to check if the file is a csv and if it is to upload it to a sqlite database for safekeeping.
#'
#' This function allows you to save the data into a sqlite database.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' save_destination_data()
load_uu_counts <- function(){
load_exposed_uu_counts <- function(file){
	uu_count <- as.data.frame(read.csv(file, header = TRUE, sep = ",", quote = "\""))
	exposed_uu_count <- as.data.frame(as.numeric(as.character(uu_count[1,2])))
	return(exposed_uu_count)
}
load_control_uu_counts <- function(file){
	uu_count <- as.data.frame(read.csv(file, header = TRUE, sep = ",", quote = "\""))
	control_uu_count <- as.data.frame(as.numeric(as.character(uu_count[2,2])))
	return(control_uu_count)
}

exposed_uu_counts <- load_exposed_uu_counts(file)
load_exposed_uu_counts <- load_control_uu_counts(file)
}