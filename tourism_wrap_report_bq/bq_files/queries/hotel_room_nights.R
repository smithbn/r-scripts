hotel_room_nights_sql <- paste0("SELECT
  event_date,
  SUM(CASE WHEN event_type = 'HOTEL_SEARCH'
    OR event_type = 'VACATION_SEARCH' THEN (number_of_nights * number_of_rooms) ELSE NULL END) AS searches,
  SUM(CASE WHEN c.event_type = 'HOTEL_CONFIRMATION'
    OR event_type = 'VACATION_CONFIRMATION' THEN (number_of_nights * number_of_rooms) ELSE NULL END) AS confirms
FROM (
  SELECT
    event_date,
    event_type,
    (CASE WHEN (event_type = 'HOTEL_SEARCH'
        OR event_type = 'HOTEL_CONFIRMATION')
      AND (check_out_date IS NOT NULL)
      AND (check_in_date IS NOT NULL) THEN DATEDIFF(check_out_date, check_in_date) WHEN (event_type = 'VACATION_SEARCH'
        OR event_type = 'VACATION_CONFIRMATION')
      AND (vacation_return_date IS NOT NULL)
      AND (vacation_departure_date IS NOT NULL) THEN DATEDIFF(vacation_return_date, vacation_departure_date) ELSE 1 END) AS number_of_nights,
    (CASE WHEN (number_of_rooms IS NOT NULL) THEN number_of_rooms ELSE 1 END) AS number_of_rooms
  FROM
    [",dest$projectId,":",dest$datasetId,".",dest$tableId,"]
  WHERE
    (event_type = 'HOTEL_SEARCH'
      OR event_type = 'HOTEL_CONFIRMATION'
      OR event_type = 'VACATION_SEARCH'
      OR event_type = 'VACATION_CONFIRMATION') ) c
GROUP BY
  event_date;")
