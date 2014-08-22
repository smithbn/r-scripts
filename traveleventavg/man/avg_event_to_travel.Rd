\name{avg_event_to_travel}
\alias{avg_event_to_travel}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
avg_event_to_travel(x)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
%%     ~~Describe \code{x} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (x) 
{
    data <- subset(x, event_type == "FLIGHT_CONFIRMATION" & event_to_travel != 
        "NULL")
    colnames(data) <- c("event_date", "event_type", "partner", 
        "origin_airport", "destination_airport", "number_of_travelers", 
        "departure_date", "return_date", "duration", "event_to_travel", 
        "num_events")
    all_days <- data.frame(rep(data$event_to_travel, times = data$num_events))
    colnames(all_days) <- "event_to_travel"
    avg_days <- mean(as.numeric(all_days$event_to_travel))
    return(avg_days)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
