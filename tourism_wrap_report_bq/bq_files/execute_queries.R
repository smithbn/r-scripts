# Run first job
# --------------------------------------------------------------------
post_impression_travel_events_job <- insert_query_job(post_impression_travel_events_sql, project, destination_table = destination_table, default_dataset = default_dataset)
post_impression_travel_events_job <- wait_for(post_impression_travel_events_job)
dest <- post_impression_travel_events_job$configuration$query$destinationTable

# Run aggregation queries and get results
# --------------------------------------------------------------------
duration_of_stay_results <- query_exec(duration_of_stay_sql, project = project, destination_table = NULL)
hotel_room_nights_results <- query_exec(hotel_room_nights_sql, project = project, destination_table = NULL)
events_by_type_results <- query_exec(events_by_type_sql, project = project, destination_table = NULL)
event_to_travel_results <- query_exec(event_to_travel_sql, project = project, destination_table = NULL)
number_in_party_results <- query_exec(number_in_party_sql, project = project, destination_table = NULL)