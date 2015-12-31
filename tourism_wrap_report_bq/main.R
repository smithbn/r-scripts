working_directory <- "~/Documents/BigQuery/tourism_wrap_report_bq"
setwd(working_directory)

source('./helper_functions/read_and_rename.R')
campaign_list <-
  read_and_rename(
    file = "./campaign_list2.csv", new_colnames = c(
      "advertiser_id","advertiser_name","campaign_name","insertion_order_id","start_date","end_date","destination_airports","destination_cities","destination_states","destination_countries"
    )
  )

for (i in 1:nrow(campaign_list)) {
  if (i > nrow(campaign_list)) {
    break
  } else {
    campaign_details <- campaign_list[i,]
    advertiser_id <- select(campaign_details, advertiser_id)[[1]]
    advertiser_name <- select(campaign_details, advertiser_name)[[1]]
    insertion_order_id <- select(campaign_details, insertion_order_id)[[1]]
    start_date <- select(campaign_details, start_date)[[1]]
    end_date <- select(campaign_details, end_date)[[1]]
    destination_airports <- select(campaign_details, destination_airports)[[1]]
    destination_cities <- select(campaign_details, destination_cities)[[1]]
    destination_states <- select(campaign_details, destination_states)[[1]]
    destination_countries <- select(campaign_details, destination_countries)[[1]]
    
    # Read in helper functions and load libraries
    # --------------------------------------------------------------------
    source(file = "./helper_functions/load_libraries.R")
    
    # BigQuery setup
    # --------------------------------------------------------------------
    source(file = "./settings/bigquery_settings.R")
    
    # Read in impression query and post-impression travel query
    # --------------------------------------------------------------------
    source(file = "./bq_files/queries/campaign_impressions.R")
    source(file = "./bq_files/queries/post_impression_travel_eventsV2.R")
    
    # Run impression and post-impression travel events jobs
    # --------------------------------------------------------------------
    campaign_impressions_job <-
      insert_query_job(
        campaign_impressions_sql, project, destination_table = campaign_impressions_destination_table, default_dataset = default_dataset
      )
    campaign_impressions_job <-
      wait_for(
        campaign_impressions_job
        )
    campaign_impressions_dest <-
      campaign_impressions_job$configuration$query$destinationTable    
    
    post_impression_travel_events_job <-
      insert_query_job(
        post_impression_travel_events_sql, project, destination_table = destination_table, default_dataset = default_dataset
      )
    post_impression_travel_events_job <-
      wait_for(
        post_impression_travel_events_job
        )
    dest <-
      post_impression_travel_events_job$configuration$query$destinationTable
    
    # Read in the other queries using the dest object destination table information
    # --------------------------------------------------------------------
    source(file = "./bq_files/get_queries.R")
    
    # Run aggregation queries and get results
    # --------------------------------------------------------------------
    duration_of_stay_results <-
      query_exec(duration_of_stay_sql, project = project, destination_table = NULL)
    hotel_room_nights_results <-
      query_exec(hotel_room_nights_sql, project = project, destination_table = NULL)
    events_by_type_results <-
      query_exec(events_by_type_sql, project = project, destination_table = NULL)
    event_to_travel_results <-
      query_exec(event_to_travel_sql, project = project, destination_table = NULL)
    number_in_party_results <-
      query_exec(number_in_party_sql, project = project, destination_table = NULL)
    number_of_travelers_results <-
      query_exec(number_of_travelers_sql, project = project, destination_table = NULL)
    search_confirm_originations_results <-
      query_exec(search_confirm_originations_sql, project = project, destination_table = NULL)
    searches_by_departure_date_results <-
      query_exec(searches_by_departure_date_sql, project = project, destination_table = NULL)
    confirms_by_departure_date_results <-
      query_exec(confirms_by_departure_date_sql, project = project, destination_table = NULL)
    post_impression_beacon_events_results <-
      query_exec(post_impression_beacon_events_sql, project = project, destination_table = NULL)
    unique_travelers_results <-
      query_exec(unique_travelers_sql, project = project, destination_table = NULL)
    
    # Create the data folder and save the query results as CSVs in that folder
    # --------------------------------------------------------------------
    source(file = "./bq_files/save_query_results.R")
    
    # Delete the post-impression travel events table and cleanup objects
    # --------------------------------------------------------------------
    source(file = "./bq_files/cleanup.R")
    
    # Create the zip folder and move to the wrap report queue where the
    # report is built.
    # --------------------------------------------------------------------
    source(file = "./bq_files/build_zip.R")
    
  }
}
# Unzip, build, screenshot, attach and e-mail the report to the account manager
# --------------------------------------------------------------------
source(file = "~/Google Drive/tourism_wrap_reports/r_source/launch_wrap_reports_dbm_bq.R")
