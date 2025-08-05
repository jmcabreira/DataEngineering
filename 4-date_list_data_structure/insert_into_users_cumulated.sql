I
-- compare today and yesterday and comulate active users into dates_active array
INSERT INTO `silent-scanner-465121-j7.jmc_data.users_cumulated` (
              user_id , 
              dates_active, -- the list of dates where the user was active
              date -- the current date for the user
                )
WITH yesterday AS ( -- active yesterday 

    SELECT * FROM silent-scanner-465121-j7.jmc_data.users_cumulated
    WHERE date = DATE('2023-01-30')

), today AS ( --active today

  SELECT 
  --user_id,
  FORMAT('%.0f', user_id) AS user_id,
  DATE(event_time) AS date_active,
  FROM silent-scanner-465121-j7.jmc_data.events
  WHERE DATE(event_time) = DATE('2023-01-31')
  AND user_id IS NOT NULL 
  GROUP BY user_id, DATE(event_time)

)
SELECT 
  -- FORMAT('%.0f', COALESCE(t.user_id, y.user_id)) AS user_id, -- convert user_id in string without decimal and coalesce 
  COALESCE(t.user_id, y.user_id), 
    CASE 
    WHEN y.dates_active IS NULL THEN [FORMAT_DATE('%F', t.date_active)]
    WHEN t.date_active IS NULL THEN y.dates_active
    ELSE [FORMAT_DATE('%F', t.date_active)] || y.dates_active
  END AS dates_active,
  DATE(COALESCE( t.date_active, y.date + INTERVAL 1 DAY )) AS date
  FROM today t 
  FULL OUTER JOIN yesterday y 
  ON t.user_id = y.user_id


--   SELECT * FROM `silent-scanner-465121-j7.jmc_data.users_cumulated`
--   where date = '2023-01-31'

