INSERT INTO `silent-scanner-465121-j7.jmc_data.players` (
  player_name,
  player_height,
  college,
  country,
  draft_year,
  draft_round,
  draft_number,
  season_stats,
  scoring_class, 
  years_since_last_season,

  current_season
)
WITH yesterday AS (
    SELECT * FROM `silent-scanner-465121-j7.jmc_data.players`
    WHERE current_season = 2000
), today AS (
      SELECT * FROM `silent-scanner-465121-j7.jmc_data.Models`
      WHERE CAST(LEFT(season,4) AS INT64) = 2001
    )
SELECT 
  COALESCE(t.player_name, y.player_name) as player_name,
  COALESCE(t.player_height, y.player_height) as height,
  COALESCE(t.college, y.college) as college,
  COALESCE(t.country, y.country) as country,
  COALESCE(t.draft_year, y.draft_year) as draft_year,
  COALESCE(t.draft_round, y.draft_round) as draft_round,
  COALESCE(t.draft_number, y.draft_number) as draft_number,
    CASE  
    WHEN y.season_stats IS NULL THEN 
      [STRUCT<season INT64, gp FLOAT64, pts FLOAT64, reb FLOAT64, ast FLOAT64>(
        CAST(LEFT(t.season, 4) AS INT64), t.gp, t.pts, t.reb, t.ast
      )]
    WHEN t.season IS NOT NULL THEN 
      y.season_stats || [STRUCT<season INT64, gp FLOAT64, pts FLOAT64, reb FLOAT64, ast FLOAT64>(
        CAST(LEFT(t.season, 4) AS INT64), t.gp, t.pts, t.reb, t.ast
      )]
    ELSE 
      y.season_stats
  END AS season_stats,
  CASE 
    WHEN t.season IS NOT NULL THEN 
       CASE WHEN t.pts > 20 then "star"
            WHEN t.pts > 15 THEN "good"
            WHEN t.pts > 10 THEN "average"
      ELSE "bad"
          END
      ELSE y.scoring_class
      END AS scoring_class,
    CASE WHEN t.season IS NOT NULL THEN 0
        ELSE y.years_since_last_season + 1
        end as years_since_last_season,
  COALESCE(CAST(LEFT(t.season, 4) AS INT64), y.current_season + 1) AS current_season
FROM today t FULL OUTER JOIN yesterday y 
  ON t.player_name = y.player_name



-- SELECT * FROM `silent-scanner-465121-j7.jmc_data.players`
-- WHERE player_name  = "Michael Jordan" and current_season = 2001