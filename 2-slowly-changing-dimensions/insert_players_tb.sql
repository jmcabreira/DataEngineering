-- create players table using cumulative table design

INSERT INTO `silent-scanner-465121-j7.jmc_data.players` (
  player_name,
  height,
  college,
  country,
  draft_year,
  draft_round,
  draft_number,
  current_season,
  season_stats,
  scoring_class, 
  seasons_played,
  years_since_last_season,
  is_ative
)
WITH years AS (
    SELECT *
    FROM UNNEST(GENERATE_ARRAY(1996, 2022)) season
), p AS (
    SELECT player_name, MIN(CAST(LEFT(season,4) AS INT64) ) as first_season
    FROM `silent-scanner-465121-j7.jmc_data.Models`
    GROUP BY player_name
), players_and_seasons AS (
    SELECT *
    FROM p
      JOIN years y ON p.first_season <= y.season
), 
player_seasons_struct AS (
SELECT
    pas.player_name,
    pas.first_season,
    pas.season AS current_season,
    ARRAY_AGG(
      STRUCT(
        CAST(LEFT(s.season,4) AS INT64) as season ,
        CAST(s.gp AS FLOAT64) AS gp,
        s.pts AS pts,
        s.reb AS reb,
        s.ast AS ast
      )
      ORDER BY s.season
    ) AS season_stats
  FROM players_and_seasons pas
  LEFT JOIN `silent-scanner-465121-j7.jmc_data.Models` s
    ON pas.player_name = s.player_name
    AND CAST(LEFT(s.season,4) AS INT64) <= pas.season
  GROUP BY pas.player_name, pas.first_season, pas.season
), static AS (
    SELECT
        player_name,
        MAX(player_height) AS height,
        MAX(college) AS college,
        MAX(country) AS country,
        MAX(draft_year) AS draft_year,
        MAX(draft_round) AS draft_round,
        MAX(draft_number) AS draft_number
    FROM  `silent-scanner-465121-j7.jmc_data.Models`
    GROUP BY player_name
),
final_tb AS (
  SELECT 
  pss.player_name,
  s.height,
  s.college,
  s.country,
  s.draft_year,
  s.draft_round,
  s.draft_number,
  pss.current_season,
  pss.season_stats,
  CASE
    WHEN ARRAY_LENGTH(season_stats) = 0 THEN 'bad'
    WHEN season_stats[(OFFSET(ARRAY_LENGTH(season_stats) - 1))].pts > 20 THEN 'star'
    WHEN season_stats[(OFFSET(ARRAY_LENGTH(season_stats) - 1))].pts > 15 THEN 'good'
    WHEN season_stats[(OFFSET(ARRAY_LENGTH(season_stats) - 1))].pts > 10 THEN 'average'
  ELSE 'Bad'
  END AS scoring_class,
  -- season_stats[(OFFSET(ARRAY_LENGTH(season_stats) - 1))].pts ,
   ARRAY_LENGTH(season_stats)  AS seasons_played,
   pss.current_season - season_stats[OFFSET(ARRAY_LENGTH(season_stats) - 1)].season AS years_since_last_active,
   season_stats[OFFSET(ARRAY_LENGTH(season_stats) - 1)].season = pss.current_season AS is_active

  FROM player_seasons_struct pss 
  JOIN static s
  ON pss.player_name = s.player_name
)
SELECT * FROM final_tb   