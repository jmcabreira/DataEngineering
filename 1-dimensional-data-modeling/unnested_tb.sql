-- back to the sold schema - unnest season_stats
SELECT 
  player_name, 
  stats.season,
  stats.gp,
  stats.pts,
  stats.reb,
  stats.ast
FROM `silent-scanner-465121-j7.jmc_data.players`,
UNNEST(season_stats) AS stats
WHERE player_name  = "Michael Jordan" and current_season = 2001