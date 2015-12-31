duration_of_stay_sql <- paste0("SELECT
  (CASE WHEN (c.duration >= 0
      AND c.duration <= 1) THEN '1 Day' WHEN (c.duration = 2) THEN '2 Days' WHEN (c.duration = 3) THEN '3 Days' WHEN (c.duration = 4) THEN '4 Days' WHEN (c.duration = 5) THEN '5 Days' WHEN (c.duration = 6) THEN '6 Days' WHEN (c.duration = 7) THEN '7 Days' WHEN (c.duration >= 8
      AND c.duration <= 14) THEN '8-14 Days' WHEN (c.duration >= 15) THEN '15+ Days' ELSE NULL END) AS duration,
  COUNT(*) AS total_count
FROM (
  SELECT
    a.profileid,
    MAX(a.duration) AS duration
  FROM (
    SELECT
      profileid,
      ( CASE WHEN event_type = 'FLIGHT_CONFIRMATION' THEN DATEDIFF(return_date, departure_date) WHEN event_type = 'HOTEL_CONFIRMATION' THEN DATEDIFF(check_out_date, check_in_date) WHEN event_type = 'CAR_CONFIRMATION' THEN DATEDIFF(rental_dropoff_date, rental_pickup_date) ELSE NULL END ) AS duration
    FROM
      [",dest$projectId,":",dest$datasetId,".",dest$tableId,"]
    WHERE
      ( event_type = 'FLIGHT_CONFIRMATION'
        OR event_type = 'HOTEL_CONFIRMATION'
        OR event_type = 'CAR_CONFIRMATION' ) ) a
  GROUP BY
    a.profileid ) c
GROUP BY
  duration;")
