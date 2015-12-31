event_to_travel_sql <- paste0("SELECT
  final.event_to_travel AS event_to_travel,
  SUM(final.Searches) AS Searches,
  SUM(final.Confirms) AS Confirms
FROM (
  SELECT
    (CASE WHEN (a.event_to_travel <= 3
        AND a.event_to_travel >= 1) THEN '1 to 3 Days Before' WHEN (a.event_to_travel <= 6
        AND a.event_to_travel >= 4) THEN '4 to 6 Days Before' WHEN (a.event_to_travel <= 9
        AND a.event_to_travel >= 7) THEN '7 to 9 Days Before' WHEN (a.event_to_travel <= 12
        AND a.event_to_travel >= 10) THEN '10 to 12 Days Before' WHEN (a.event_to_travel <= 20
        AND a.event_to_travel >= 13) THEN '13 to 20 Days Before' WHEN (a.event_to_travel <= 30
        AND a.event_to_travel >= 21) THEN '21 to 30 Days Before' WHEN (a.event_to_travel <= 40
        AND a.event_to_travel >= 31) THEN '31 to 40 Days Before' WHEN (a.event_to_travel <= 50
        AND a.event_to_travel >= 41) THEN '41 to 50 Days Before' WHEN (a.event_to_travel <= 60
        AND a.event_to_travel >= 51) THEN '51 to 60 Days Before' WHEN (a.event_to_travel <= 70
        AND a.event_to_travel >= 61) THEN '61 to 70 Days Before' WHEN (a.event_to_travel <= 80
        AND a.event_to_travel >= 71) THEN '71 to 80 Days Before' WHEN (a.event_to_travel > 90) THEN 'More than 90 Days Before' WHEN (a.event_to_travel = 0) THEN 'Same Day' ELSE NULL END) AS event_to_travel,
    (CASE WHEN (event_type = 'FLIGHT_SEARCH'
        OR event_type = 'HOTEL_SEARCH'
        OR event_type = 'CAR_SEARCH'
        OR event_type = 'VACATION_SEARCH') THEN 1 ELSE NULL END) AS Searches,
    (CASE WHEN (event_type = 'FLIGHT_CONFIRMATION'
        OR event_type = 'HOTEL_CONFIRMATION'
        OR event_type = 'CAR_CONFIRMATION') THEN 1 ELSE NULL END) AS Confirms
  FROM (
    SELECT
      event_type,
      (CASE WHEN (event_type = 'FLIGHT_SEARCH'
          OR event_type = 'FLIGHT_CONFIRMATION') THEN DATEDIFF(departure_date, event_date) WHEN (event_type = 'HOTEL_CONFIRMATION'
          OR event_type = 'HOTEL_SEARCH') THEN DATEDIFF(check_in_date, event_date) WHEN (event_type = 'CAR_CONFIRMATION'
          OR event_type = 'CAR_SEARCH') THEN DATEDIFF(rental_pickup_date, event_date) WHEN (event_type = 'VACATION_CONFIRMATION'
          OR event_type = 'VACATION_SEARCH') THEN DATEDIFF(vacation_departure_date, event_date) ELSE NULL END) AS event_to_travel
    FROM
      [",dest$projectId,":",dest$datasetId,".",dest$tableId,"] ) a ) final
GROUP BY
  event_to_travel;")
