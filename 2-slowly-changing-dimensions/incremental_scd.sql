

WITH last_season_scd AS (
    SELECT * FROM `silent-scanner-465121-j7.jmc_data.players_scd`
    WHERE current_season = 2021
), this_season_data AS (
    SELECT * FROM `silent-scanner-465121-j7.jmc_data.players_scd`
    WHERE current_season = 2022
), this_season_data(ß
    SELECT * FROM `silent-scanner-465121-j7.jmc_data.players`
    WHERE current_season = 2022

)
SELECT * FROM last_season_scd