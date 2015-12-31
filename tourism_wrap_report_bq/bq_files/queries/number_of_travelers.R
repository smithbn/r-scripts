number_of_travelers_sql <- paste0("SELECT
  SUM(CASE WHEN c.experiment_bucket = 'Exposed' THEN c.number_of_travelers ELSE NULL END) AS total_exposed_travelers,
                                  SUM(CASE WHEN c.experiment_bucket = 'Control' THEN c.number_of_travelers ELSE NULL END) AS total_control_travelers
                                  FROM (
                                  SELECT
                                  a.experiment_bucket,
                                  a.profileid,
                                  (CASE WHEN a.event_type = 'FLIGHT_CONFIRMATION' THEN a.departure_date WHEN a.event_type = 'HOTEL_CONFIRMATION' THEN a.check_in_date WHEN a.event_type = 'CAR_CONFIRMATION' THEN a.rental_pickup_date WHEN a.event_type = 'VACATION_CONFIRMATION' THEN a.vacation_departure_date ELSE NULL END) AS travel_date,
                                  MAX(a.number_of_travelers) AS number_of_travelers
                                  FROM (
                                  SELECT
                                  experiment_bucket,
                                  profileid,
                                  event_type,
                                  departure_date,
                                  check_in_date,
                                  rental_pickup_date,
                                  vacation_departure_date,
                                  (CASE WHEN number_of_travelers = 0 THEN 1 WHEN number_of_travelers IS NULL THEN 1 ELSE number_of_travelers END) AS number_of_travelers
                                  FROM
                                  [",dest$projectId,":",dest$datasetId,".",dest$tableId,"] ) a
                                  WHERE
                                  (event_type = 'FLIGHT_CONFIRMATION'
                                  OR event_type = 'HOTEL_CONFIRMATION'
                                  OR event_type = 'CAR_CONFIRMATION'
                                  OR event_type = 'VACATION_CONFIRMATION' )
                                  GROUP BY
                                  a.experiment_bucket,
                                  a.profileid,
                                  travel_date ) c;")