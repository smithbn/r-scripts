searches_by_departure_date_sql <- paste0("SELECT departure_date, count(*) 
FROM [",dest$projectId,":",dest$datasetId,".",dest$tableId,"]
WHERE event_type = 'FLIGHT_SEARCH' 
AND departure_date IS NOT NULL 
AND departure_date >= '",start_date,"'
GROUP BY departure_date;")