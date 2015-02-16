#' A control group randomizer function
#'
#' This function builds a randomized list of cities.
#' @param iata_code, exposed_country, number, minimum, maximum
#' @keywords map
#' @export
#' @examples
#' getCityList()
 
getCityList = function(iata_code, exposed_country, number, minimum, maximum){
    setwd("~/databases")
    my_db <- src_sqlite("my_db.sqlite3")
	cities_tbl <- tbl(my_db, "cities")
    City_List <- as.data.frame(filter(cities_tbl, city != 'NULL', country == exposed_country, total >= minimum, total <= maximum, destination_airport == iata_code))
    City_List <- sample_n(City_List, number, replace = TRUE)
	City_List <- mutate(City_List, full_name = as.character(paste(City_List$city, City_List$region, City_List$country, sep = ", ")))
	City_List[,7:8] <- geocode(City_List$full_name)
	City_List <- City_List[c(8,7,1,2,3,4,5,6)]
	City_List <- toGeoJSON(City_List)
    return(City_List)
}

#' A control group chart generator function
#'
#' This function charts the cities.
#' @param iata_code, exposed_country, number, minimum, maximum
#' @keywords chart
#' @export
#' @examples
#' cityChart()

cityChart <- function(iata_code, exposed_country, number, minimum, maximum){
    data = getCityList(iata_code, exposed_country, number, minimum, maximum)
    n1 <- rPlot(total ~ city, 
    data = data, 
	type = "bar", 
	color = "total",
	height = 50,
	width = 60
	)
  return(n1)
}

#' A control group map generator function
#'
#' This function plots the cities and DMAs on a map.
#' @param iata_code, exposed_country, number, minimum, maximum
#' @keywords map
#' @export
#' @examples
#' cityMap()

cityMap <- function(iata_code, exposed_country, number, minimum, maximum, width = 1600, height = 800){
    library("leafletR")
	library("dplyr")
	library("ggmap")
	library("ggplot2")
	library("RJSONIO")
    City_List_ <- getCityList(iata_code, exposed_country, number, minimum, maximum)
	setwd("~/databases")
    sty.1 <- styleSingle(col = "black", fill = "black", lwd = 1, fill.alpha = 0.25, alpha = 1)
    sty.2 <- styleSingle(col = "black", fill = "orange", rad = 4, fill.alpha = 1, alpha = 1)
    popup.1 <- c("dma1","adsperc")
    popup.2 <- c("city", "region", "country", "total")
    map <- leaflet(data=list("dma.json", City_List_), title = "index", base.map = "osm",incl.data = TRUE, zoom=3, style = list(sty.1, sty.2), popup = list(popup.1, popup.2))
    return(map)
}

#' A chart saving function
#'
#' This function saves the chart.
#' @param iata_code, exposed_country, number, minimum, maximum
#' @keywords chart
#' @export
#' @examples
#' saveChart()

saveChart <- function(iata_code, exposed_country, number, minimum, maximum){
  n1 <- cityMap(iata_code, exposed_country, number, minimum, maximum)
  n1$set(height = 700)
  n1$save('output.html', cdn = T)
  return(invisible())
}

#' A function to put the chart in HTML
#'
#' This function puts the chart in HTML.
#' @param iata_code, exposed_country, number, minimum, maximum
#' @keywords chart
#' @export
#' @examples
#' inlineChart()

inlineChart <- function(iata_code, exposed_country, number, minimum, maximum){
  n1 <- cityMap(iata_code, exposed_country, number, minimum, maximum)
  n1$set(height = 650)
  paste(capture.output(n1$show('inline')), collapse ='\n')
}