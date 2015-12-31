post_impression_beacon_events_sql <- paste0("SELECT
pixelid,
                                            COUNT(DISTINCT user_id, 50000) AS uu_count_soj,
                                            COUNT(*) AS total_beacon_fires_soj,
                                            name
                                            FROM (
                                            SELECT
                                            adv_beacons.name as name,
                                            final.pixelid as pixelid,
                                            final.user_id as user_id,
                                            final.occurred_date as occurred_date
                                            FROM (
                                            SELECT advertiser_id AS advertiser_id,
                                            name AS name,
                                            id AS id
                                            FROM (TABLE_DATE_RANGE(navigator_dataset.navi_api, TIMESTAMP('",start_date,"'), TIMESTAMP('",end_date,"')))
                                            WHERE
                                            advertiser_id = ",advertiser_id,") adv_beacons
                                            LEFT JOIN (
                                            SELECT
                                            soj_beacons.pixelid as pixelid,
                                            soj_beacons.user_id as user_id,
                                            soj_beacons.occurred_date as occurred_date
                                            FROM (
                                            SELECT
                                            impression_date,
                                            dmp_user_id
                                            FROM
                                            [",dest$projectId,":",campaign_impressions_destination_table,"]
                                            WHERE
                                            experiment_bucket = 'Exposed' ) imp_users_sojern_ids
                                            JOIN (
                                            SELECT
                                            DATE(EpochTime) AS beacon_date,
                                            EpochTime AS occurred_date,
                                            INTEGER(Data.pixelId) AS pixelid,
                                            GoogleGid AS user_id
                                            FROM (TABLE_DATE_RANGE(smp_events_dataset.smp_events_daily, TIMESTAMP('",start_date,"'), TIMESTAMP('",end_date,"')))
                                            WHERE
                                            EventSourceName = '",advertiser_name,"'
                                            AND GoogleGid IS NOT NULL
                                            AND GoogleGid != '') soj_beacons
                                            ON
                                            (imp_users_sojern_ids.dmp_user_id = soj_beacons.user_id)
                                            WHERE
                                            ( imp_users_sojern_ids.impression_date <= soj_beacons.beacon_date
                                            AND DATEDIFF(soj_beacons.beacon_date, imp_users_sojern_ids.impression_date) <= 30 ) 
                                            GROUP BY pixelid,
                                            user_id,
                                            occurred_date) final
                                            ON
                                            (final.pixelid = adv_beacons.id) 
                                            GROUP BY name,
                                            pixelid,
                                            user_id,
                                            occurred_date) summarize
                                            GROUP BY
                                            name,
                                            pixelid;")