#' A function to create heatmap calendars from event data.
#'
#' This function creates one heatmap calendar with a bar chart above.
#' @param file read in a csv file.
#' @keywords event data
#' @export
#' @examples
#' heatmap_calendar_big()
heatmap_calendar_big <- function(mydata){
    
    require('lubridate')
    require('ggplot2')
    require('plyr')
    require('timeDate')
    require('grid')
    require('RColorBrewer')
    
    cal <- function(dt) {
        # Reads a date object and returns a tuple (weekrow, daycol)
        # where weekrow starts at 1 and daycol starts at 1 for Sunday
        year <- year(dt)
        month <- month(dt)
        day <- day(dt)
        wday_first <- wday(ymd(paste(year, month, 1, sep = '-'), quiet = TRUE))
        offset <- 7 + (wday_first - 2)
        weekrow <- ((day + offset) %/% 7) - 1
        daycol <- (day + offset) %% 7
        
        c(weekrow, daycol)
    }
    weekrow <- function(dt) {
        cal(dt)[1]
    }
    daycol <- function(dt) {
        cal(dt)[2]
    }
    vweekrow <- function(dts) {
        sapply(dts, weekrow)
    }
    vdaycol <- function(dts) {
        sapply(dts, daycol)
    }
    
    #----------------------------------
    # Heatmap Calendar
    #----------------------------------
    daily_events <- mydata
    colnames(daily_events) <- c("event_date", "event_num")
    daily_events$event_date <- as.Date(daily_events$event_date)
    dailymean <- mean(daily_events[,'event_num'], na.rm=TRUE)
    daily_events$difference_from_mean <- daily_events$event_num - dailymean
    daily_events$month <- month(daily_events$event_date, label = TRUE, abbr = TRUE)
    daily_events$year <- year(daily_events$event_date)
    daily_events$weekrow <- factor(vweekrow(daily_events$event_date), levels = c(5, 4, 3, 2, 1, 0), labels = c('6', '5', '4', '3', '2', '1'))
    daily_events$daycol <- factor(vdaycol(daily_events$event_date), labels = c('Su', 'M', 'T', 'W', 'Th', 'F', 'Sa'))
    daily_events$day <- day(daily_events$event_date)
    names(daily_events)[names(daily_events)=="event_num"]  <- "Difference from Mean"
    
    p1 <- ggplot(data = daily_events, aes(x = event_date, y = difference_from_mean)) + geom_bar(colour="white", width=0.75, stat="identity") + theme_bw() + labs(x="", y="Difference from Mean") + scale_x_date(labels = date_format("%b-%y"), breaks = date_breaks("month")) + scale_fill_brewer() +
        theme(axis.text.x = element_text(size=9),
              axis.text.y = element_text(size=9),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_text(size=15),
              axis.title.y = element_text(size=15),
              legend.position = "left",
              legend.key = element_blank(),
              legend.key.width = unit(0.25, "in"),
              legend.key.height = unit(0.5, "in"),
              legend.margin = unit(0, "in"),
              legend.box = 'horizontal',
              strip.text = element_text(size=15))
    p2 <- ggplot(data = subset(daily_events, year > max(daily_events$year) - 11),
                 aes(x = daycol, y = weekrow, fill = difference_from_mean)) +
        theme_bw() + 
        theme(axis.text.x = element_text(size=9),
              axis.text.y = element_blank(),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank(),
              legend.position = "left",
              legend.key = element_blank(),
              legend.key.width = unit(0.25, "in"),
              legend.key.height = unit(0.5, "in"),
              legend.margin = unit(0, "in"),
              legend.box = 'horizontal',
              strip.text = element_text(size=15)) +
        geom_tile(colour = "white") +
        geom_text(aes(label=day, size=0.1)) +
        facet_grid(year ~ month) +
        scale_fill_gradientn(colours=brewer.pal(9,"YlOrRd"), name="Difference\nfrom Mean")
    png("heatmap.png", width= 1500)
    print(
        grid.arrange(p1, p2, ncol=1)
    )
    dev.off()
    
}