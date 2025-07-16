
-- assumptions I need to be aware of :
-- scoring_class and is_active is never null 

WITH last_season_scd AS (
    SELECT *  FROM `silent-scanner-465121-j7.jmc_data.players_scd`
    WHERE current_season = 2021
    AND end_season = 2021
), historical_scd AS (
    SELECT 
    player_name, 
    scoring_class,
    is_ative, 
    start_season,
    end_season
    FROM `silent-scanner-465121-j7.jmc_data.players_scd`
    WHERE current_season = 2021
    AND end_season < 2021
), this_season_data  AS (
    SELECT * FROM `silent-scanner-465121-j7.jmc_data.players`
    WHERE current_season = 2022
), unchanged_records AS (
    SELECT  
        ts.player_name,
        ts.scoring_class,
        ts.is_ative,
        ls.start_season,
        ts.current_season AS end_season
       FROM  this_season_data  ts 
    JOIN last_season_scd ls
    ON ls.player_name = ts.player_name 
    WHERE  ts.scoring_class = ls.scoring_class
    AND    ts.is_ative = ls.is_ative
), changed_records AS ( -- create an array with last and this season info for changed records)
SELECT 
        ts.player_name,
        --scd_info.source,
        scd_info.scoring_class,
        scd_info.is_ative,
        scd_info.start_season,
        scd_info.end_season
       FROM  this_season_data  ts 
    LEFT JOIN last_season_scd ls
    ON ls.player_name = ts.player_name,
    UNNEST(ARRAY<STRUCT<
   --- source STRING,
    scoring_class STRING,
    is_ative BOOL,
    start_season INT64,
    end_season INT64
  >>[
    STRUCT(
      --'last_season' AS source,
      ls.scoring_class,
      ls.is_ative,
      ls.start_season,
      ls.end_season
    ),
    STRUCT(
     -- 'this_season' AS source,
      ts.scoring_class,
      ts.is_ative,
      ts.current_season,
      ts.current_season
    )
  ] ) AS scd_info 
    WHERE  ts.scoring_class <> ls.scoring_class OR  ts.is_ative  <> ls.is_ative

) ,  new_records AS (
    SELECT
        ts.player_name,
        ts.scoring_class, 
        ts.is_ative,
        ts.current_season as start_season,
        ts.current_season as end_season
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls 
    ON ts.player_name = ls.player_name
    WHERE ls.player_name IS NULL
)

SELECT * FROM historical_scd

UNION ALL 

SELECT * FROM unchanged_records

UNION ALL 

SELECT * FROM changed_records

UNION ALL 

SELECT * FROM new_records






