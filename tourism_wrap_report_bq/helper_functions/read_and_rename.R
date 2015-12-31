read_and_rename <- function(file, new_colnames, ... ){
  data <- read.csv(file, header = FALSE, sep = "|")
  colnames(data) <- new_colnames
  return(data)
}