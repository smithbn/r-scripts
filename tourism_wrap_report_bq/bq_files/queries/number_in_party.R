number_in_party_sql <- paste0("SELECT
  (CASE WHEN (c.number_of_travelers = 1) THEN '1 traveler' WHEN (c.number_of_travelers = 2) THEN '2 travelers' WHEN (c.number_of_travelers = 3) THEN '3 travelers' WHEN (c.number_of_travelers = 4) THEN '4 travelers' WHEN (c.number_of_travelers = 5) THEN '5 travelers' WHEN (c.number_of_travelers >= 6) THEN '6+ travelers' ELSE NULL END) AS number_of_travelers,
  COUNT(*) AS total_count
FROM (
  SELECT
    a.profileid,
    MAX(a.number_of_travelers) AS number_of_travelers
  FROM (
    SELECT
      profileid,
      ( CASE WHEN number_of_travelers IS NOT NULL THEN number_of_travelers ELSE 1 END ) AS number_of_travelers
    FROM
      [",dest$projectId,":",dest$datasetId,".",dest$tableId,"]
    WHERE
      ( event_type = 'FLIGHT_CONFIRMATION'
        OR event_type = 'HOTEL_CONFIRMATION'
        OR event_type = 'CAR_CONFIRMATION' ) ) a
  GROUP BY
    a.profileid ) c
GROUP BY
  number_of_travelers;")
