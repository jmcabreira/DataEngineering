
-- improvement from first season to the latest season of each player
SELECT 
player_name,
season_stats[OFFSET(array_length(season_stats) - 1 )].pts / CASE WHEN season_stats[OFFSET(0)].pts = 0 THEN 1 ELSE season_stats[OFFSET(0)].pts END AS improvement,
 FROM `silent-scanner-465121-j7.jmc_data.players`
where current_season = 2001