 -- full load process
 INSERT INTO  `silent-scanner-465121-j7.jmc_data.players_scd` (
              player_name , 
              scoring_class , 
              is_ative ,
              start_season ,
              end_season ,
              current_season 
                )
WITH with_previous AS (
SELECT 
  player_name,
  current_season,
  scoring_class,
  is_ative as is_active,
  LAG(scoring_class, 1 ) OVER (PARTITION BY player_name order by current_season)  as previous_scoring_class,
  LAG(is_ative, 1 ) OVER (PARTITION BY player_name order by current_season)  as previous_is_active
FROM `silent-scanner-465121-j7.jmc_data.players`
WHERE current_season <= 2001

), with_indicators AS (
SELECT 
    *,
    CASE 
      WHEN scoring_class  <> previous_scoring_class THEN 1 
      WHEN is_active  <> previous_is_active  THEN 1 
      ELSE 0
    END AS change_indicator,
FROM with_previous 
), with_streaks AS (
SELECT 
* ,
SUM(change_indicator) OVER (PARTITION BY player_name ORDER BY current_season) as streak_identifier
FROM with_indicators
)

SELECT 
  player_name, 
  scoring_class,
  is_active, 
  MIN(current_season) as start_season,
  MAX(current_season) as end_season,
  --streak_identifier,
  2021 as current_season
 FROM with_streaks
GROUP BY player_name,streak_identifier,  is_active, scoring_class
ORDER BY player_name,streak_identifier 