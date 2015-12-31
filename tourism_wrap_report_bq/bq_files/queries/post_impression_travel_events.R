post_impression_travel_events_sql <- paste0("SELECT
  events.experiment_bucket AS experiment_bucket,
  events.profileid AS profileid,
  events.event_date AS event_date,
  events.occurred_date AS occurred_date,
  CASE WHEN events.partner = 'Avis Budget Group' AND events.pixelid = '1473' THEN 'CAR_SEARCH'
  WHEN events.partner = 'Avis Budget Group' AND events.pixelid = '1458' THEN 'CAR_CONFIRMATION'
  WHEN events.partner = 'Hertz International' AND events.pixelid = '6260' THEN 'CAR_CONFIRMATION' 
  WHEN events.partner = 'Hertz International' AND events.pixelid = '6257' THEN 'CAR_SEARCH'
  WHEN events.partner = 'Fox Rent A Car' AND events.pixelid = '2104' THEN 'CAR_CONFIRMATION'
  WHEN events.partner = 'Sabre Hospitality' AND events.pixelid = '5977' THEN 'HOTEL_CONFIRMATION'
  WHEN events.partner = 'Aeromexico' AND events.pixelid = '8451' THEN 'FLIGHT_SEARCH'
  WHEN events.partner = 'APAC Singapore Airlines' AND events.pixelid = '5013' THEN 'FLIGHT_SEARCH'
  WHEN events.partner = 'Despegar' AND events.pixelid = '3340' THEN 'FLIGHT_SEARCH'
  WHEN events.partner = 'EU Alitalia' AND events.pixelid = '6251' THEN 'FLIGHT_SEARCH'
  WHEN events.partner = 'EU Cheap Flight' AND events.pixelid = '3738' THEN 'FLIGHT_SEARCH'
  WHEN events.partner = 'EU Iberia' AND events.pixelid = '1316' THEN 'FLIGHT_SEARCH'
  WHEN events.partner = 'EU Netflights' AND events.pixelid = '6104' THEN 'FLIGHT_SEARCH'
  WHEN events.partner = 'Marriott' AND events.pixelid = '1331' THEN 'HOTEL_SEARCH'
  ELSE events.event_type END AS event_type,
  events.partner AS partner,
  events.origin_airport AS origin_airport,
  events.destination_airport AS destination_airport,
  events.departure_date AS departure_date,
  events.return_date AS return_date,
  events.number_of_travelers AS number_of_travelers,
  events.hotel_city AS hotel_city,
  events.hotel_state AS hotel_state,
  events.hotel_country AS hotel_country,
  events.check_in_date AS check_in_date,
  events.check_out_date AS check_out_date,
  events.number_of_rooms AS number_of_rooms,
  events.rental_city AS rental_city,
  events.rental_pickup_airport AS rental_pickup_airport,
  events.rental_dropoff_city AS rental_dropoff_city,
  events.rental_pickup_date AS rental_pickup_date,
  events.rental_dropoff_date AS rental_dropoff_date,
  events.vacation_airport_origin AS vacation_airport_origin,
  events.vacation_airport_destination AS vacation_airport_destination,
  events.vacation_departure_date AS vacation_departure_date,
  events.vacation_return_date AS vacation_return_date
FROM (
  SELECT smp_events.pixelid,
    imp_users_sojern_ids.experiment_bucket AS experiment_bucket,
    imp_users_sojern_ids.dmp_user_id AS profileid,
    smp_events.event_date AS event_date,
    smp_events.occurred_date AS occurred_date,
    smp_events.event_type AS event_type,
    smp_events.partner AS partner,
    SUBSTR(smp_events.origin_airport, 1, 3) AS origin_airport,
    smp_events.destination_airport AS destination_airport,
    smp_events.departure_date AS departure_date,
    smp_events.return_date AS return_date,
    smp_events.number_of_travelers AS number_of_travelers,
    smp_events.hotel_city AS hotel_city,
    smp_events.hotel_state AS hotel_state,
    smp_events.hotel_country AS hotel_country,
    smp_events.check_in_date AS check_in_date,
    smp_events.check_out_date AS check_out_date,
    smp_events.number_of_rooms AS number_of_rooms,
    smp_events.rental_city AS rental_city,
    smp_events.rental_pickup_airport AS rental_pickup_airport,
    smp_events.rental_dropoff_city AS rental_dropoff_city,
    smp_events.rental_pickup_date AS rental_pickup_date,
    smp_events.rental_dropoff_date AS rental_dropoff_date,
    SUBSTR(smp_events.vacation_airport_origin, 1, 3) AS vacation_airport_origin,
    smp_events.vacation_airport_destination AS vacation_airport_destination,
    smp_events.vacation_departure_date AS vacation_departure_date,
    smp_events.vacation_return_date AS vacation_return_date
  FROM (
    SELECT
      impression_date,
      timestamp,
      dmp_user_id,
      experiment_bucket
    FROM
      [",project,":",campaign_impressions_destination_table,"] ) imp_users_sojern_ids
  JOIN EACH (
    SELECT STRING(Data.pixelId) AS pixelid,
      DATE(EpochTime) AS event_date,
      EpochTime AS occurred_date,
      GoogleGid AS googlegid,
      EventType AS event_type,
      EventSourceName AS partner,
      Data.fa1 AS origin_airport,
      Data.fa2 AS destination_airport,
      DATE(Data.fd1) AS departure_date,
      DATE(Data.fd2) AS return_date,
      data.t AS number_of_travelers,
      data.hc1 AS hotel_city,
      data.hs1 AS hotel_state,
      data.hn1 AS hotel_country,
      DATE(data.hd1) AS check_in_date,
      DATE(data.hd2) AS check_out_date,
      data.hr AS number_of_rooms,
      data.rc1 AS rental_city,
      data.ra1 AS rental_pickup_airport,
      data.rc2 AS rental_dropoff_city,
      DATE(data.rd1) AS rental_pickup_date,
      DATE(data.rd2) AS rental_dropoff_date,
      data.va1 AS vacation_airport_origin,
      data.va2 AS vacation_airport_destination,
      DATE(data.vd1) AS vacation_departure_date,
      DATE(data.vd2) AS vacation_return_date
    FROM (TABLE_DATE_RANGE(smp_events_dataset.smp_events_daily, TIMESTAMP('",start_date,"'), DATE_ADD(TIMESTAMP('",end_date,"'), 30, 'DAY')))
    WHERE
      GoogleGid != ''
      AND GoogleGid IS NOT NULL
      AND ( Data.fa2 IN (",destination_airports,")
        OR data.va2 IN (",destination_airports,")
        OR (data.hc1 IN (",destination_cities,")
          AND data.hs1 IN (",destination_states,")
          AND data.hn1 IN (",destination_countries,"))
        OR data.rc1 IN (",destination_cities,")
        OR data.ra1 IN (",destination_airports,")
        OR data.ra1 IN  (",destination_cities,"))) smp_events
  ON
    (imp_users_sojern_ids.dmp_user_id = smp_events.googlegid)
  WHERE
    ( imp_users_sojern_ids.impression_date <= smp_events.event_date
      AND DATEDIFF(smp_events.event_date, imp_users_sojern_ids.impression_date) <= 30 ) ) events
GROUP BY
  experiment_bucket,
  profileid,
  event_date,
  occurred_date,
  event_type,
  partner,
  origin_airport,
  destination_airport,
  departure_date,
  return_date,
  number_of_travelers,
  hotel_city,
  hotel_state,
  hotel_country,
  check_in_date,
  check_out_date,
  number_of_rooms,
  rental_city,
  rental_pickup_airport,
  rental_dropoff_city,
  rental_pickup_date,
  rental_dropoff_date,
  vacation_airport_origin,
  vacation_airport_destination,
  vacation_departure_date,
  vacation_return_date;")