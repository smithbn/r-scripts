events_by_type_sql <- paste0("SELECT
  event_type AS event_type,
  COUNT(*) AS num_events,
  MAX(duration) AS duration,
  MAX(number_of_travelers) AS number_of_travelers,
  MAX(event_to_travel) AS event_to_travel
FROM (
  SELECT
    a.event_type AS event_type,
    PERCENTILE_CONT(0.5) OVER (PARTITION BY a.event_type ORDER BY a.duration) AS duration,
    PERCENTILE_CONT(0.5) OVER (PARTITION BY a.event_type ORDER BY a.number_of_travelers) AS number_of_travelers,
    PERCENTILE_CONT(0.5) OVER (PARTITION BY a.event_type ORDER BY a.event_to_travel) AS event_to_travel
  FROM (
    SELECT
      event_type,
      (CASE WHEN event_type = 'BOARDING_PASS' THEN DATEDIFF(return_date, departure_date) WHEN event_type = 'FLIGHT_CONFIRMATION' THEN DATEDIFF(return_date, departure_date) WHEN event_type = 'FLIGHT_SEARCH' THEN DATEDIFF(return_date, departure_date) WHEN event_type = 'HOTEL_CONFIRMATION' THEN DATEDIFF(check_out_date, check_in_date) WHEN event_type = 'HOTEL_SEARCH' THEN DATEDIFF(check_out_date, check_in_date) WHEN event_type = 'CAR_CONFIRMATION' THEN DATEDIFF(rental_dropoff_date, rental_pickup_date) WHEN event_type = 'CAR_SEARCH' THEN DATEDIFF(rental_dropoff_date, rental_pickup_date) WHEN event_type = 'VACATION_SEARCH' THEN DATEDIFF(vacation_return_date, vacation_departure_date) WHEN event_type = 'VACATION_CONFIRMATION' THEN DATEDIFF(vacation_return_date, vacation_departure_date) ELSE NULL END ) AS duration,
      (CASE WHEN number_of_travelers IS NOT NULL THEN number_of_travelers ELSE 1 END ) AS number_of_travelers,
      (CASE WHEN event_type = 'BOARDING_PASS' THEN DATEDIFF(departure_date, event_date) WHEN event_type = 'FLIGHT_CONFIRMATION' THEN DATEDIFF(departure_date, event_date) WHEN event_type = 'FLIGHT_SEARCH' THEN DATEDIFF(departure_date, event_date) WHEN event_type = 'HOTEL_CONFIRMATION' THEN DATEDIFF(check_in_date, event_date) WHEN event_type = 'HOTEL_SEARCH' THEN DATEDIFF(check_in_date, event_date) WHEN event_type = 'CAR_CONFIRMATION' THEN DATEDIFF(rental_pickup_date, event_date) WHEN event_type = 'CAR_SEARCH' THEN DATEDIFF(rental_pickup_date, event_date) WHEN event_type = 'VACATION_SEARCH' THEN DATEDIFF(vacation_departure_date, event_date) WHEN event_type = 'VACATION_CONFIRMATION' THEN DATEDIFF(vacation_departure_date, event_date) ELSE NULL END ) AS event_to_travel
    FROM
      [",dest$projectId,":",dest$datasetId,".",dest$tableId,"]
    WHERE
      experiment_bucket = 'Exposed') a ) final
GROUP BY
  event_type;")
