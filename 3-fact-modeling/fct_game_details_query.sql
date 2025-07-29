INSERT INTO `silent-scanner-465121-j7.jmc_data.fct_game_details` (
    dim_game_date, 
    dim_season,
    dim_team_id, 
    dim_player_id,
    dim_player_name,
    dim_start_position,
    dim_is_playing_at_home,
    dim_did_not_play,
    dim_did_not_dress,
    dim_not_with_team,
    m_minutes,
    m_fgm,
    m_fga,
    m_fg3m,
    m_fg3a,
    m_ftm,
    m_fta,
    m_oreb,
    m_dreb,
    m_reb,
    m_ast,
    m_stl,
    m_blk,
    m_turnovers,
    m_pf,
    m_pts,
    m_plus_minus
)
WITH deduped as (
  SELECT 
  g.game_date_est,
  g.season,
  g.home_team_id,
  gd.*,
  ROW_NUMBER() OVER(PARTITION BY gd.player_id, gd.game_id, gd.team_id ORDER BY  g.game_date_est ) AS rn 
  FROM silent-scanner-465121-j7.jmc_data.game_details gd 
  JOIN silent-scanner-465121-j7.jmc_data.games g 
  ON g.game_id = gd.game_id
  qualify rn = 1
)
SELECT 
  game_date_est AS  dim_game_date,
  season as dim_season,
  team_id as dim_team_id,
  player_id as dim_player_id,
  player_name as dim_player_name,
  start_position as dim_start_position,
  team_id = home_team_id as dim_is_playing_at_home,
  STRPOS(IFNULL(comment, ''), 'DNP') > 0 AS dim_did_not_play,
  STRPOS(IFNULL(comment, ''), 'DND') > 0 AS dim_did_not_dress,
  STRPOS(IFNULL(comment, ''), 'NWT') > 0 AS dim_not_with_team,
  SAFE_CAST(SPLIT(min, ':')[OFFSET(0)] AS FLOAT64) +
  SAFE_CAST(SPLIT(min, ':')[OFFSET(1)] AS FLOAT64) / 60 AS m_minutes,
  fgm as m_fgm ,
  fga as m_fga,
  fg3m as m_fg3m,
  fg3a as m_fg3a,
  ftm as m_ftm,
  fta as m_fta,
  oreb as  m_oreb,
  dreb as m_dreb,   
  reb as m_reb,
  ast as m_ast,
  stl as m_stl,
  blk as m_blk,
  `TO` AS m_turnovers,  
  pf as m_pf,
  pts as m_pts,
  plus_minus as m_plus_minus
 FROM deduped

