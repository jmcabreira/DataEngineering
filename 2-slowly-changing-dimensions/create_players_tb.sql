CREATE TABLE `silent-scanner-465121-j7.jmc_data.players` (
              player_name STRING, 
              height FLOAT64,
              college STRING,
              country STRING,
              draft_year STRING,
              draft_round STRING,
              draft_number STRING,
              current_season INT64,
              season_stats ARRAY<STRUCT<
                                    season INT64, 
                                    gp FLOAT64, 
                                    pts FLOAT64, 
                                    reb FLOAT64, 
                                    ast FLOAT64>>,
              scoring_class STRING, 
              seasons_played INT64,
              years_since_last_season INT64,
              is_ative BOOLEAN
                )
