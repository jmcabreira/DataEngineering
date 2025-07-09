 -- create bigquery table for cumulative dimensions 
CREATE TABLE `silent-scanner-465121-j7.jmc_data.players` (
              player_name STRING, 
              player_height FLOAT64,
              college STRING,
              country STRING,
              draft_year STRING,
              draft_round STRING,
              draft_number STRING,
              season_stats ARRAY<STRUCT<
                                    season INT64, 
                                    gp FLOAT64, 
                                    pts FLOAT64, 
                                    reb FLOAT64, 
                                    ast FLOAT64>>,
              current_season INT64
                )