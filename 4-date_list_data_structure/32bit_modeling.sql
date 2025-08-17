-- data modeling - user_id	activity_mask	binary_32bit	bits_on_count	monthly_active	weekly_active	daily_active
-- Uses binary 32 bits in order to identify active users ( monthly, wewkly and daily )
WITH users AS (
SELECT * 
FROM silent-scanner-465121-j7.jmc_data.users_cumulated
WHERE date = '2023-01-31'
), series AS (
SELECT *
FROM UNNEST(GENERATE_DATE_ARRAY('2023-01-02', '2023-01-31')) AS series_date
), 
place_holder_ints AS (
SELECT *, 
STRING(series_date) IN UNNEST(dates_active) AS is_active_on_date,
DATE_DIFF(date, series_date, DAY) AS days_since,
CASE WHEN 
  STRING(series_date) IN UNNEST(dates_active)
THEN CAST(POW(2 ,  32 - DATE_DIFF(date, series_date, DAY) -1 ) AS INT64)
ELSE 0
END AS place_holder_int_value
FROM users CROSS JOIN series 
-- WHERE user_id = '6217025997859493200'
ORDER BY series_date
) ,
bit_32 as (
SELECT *,
(
  SELECT STRING_AGG(CAST(((place_holder_int_value >> (31 - i)) & 1) AS STRING), '')
  FROM UNNEST(GENERATE_ARRAY(0, 31)) AS i
) AS binary_32bit
FROM place_holder_ints
)
, bitmask AS ( 
SELECT 
user_id, 
sum(place_holder_int_value) as activity_mask
FROM bit_32
GROUP BY user_id
), total_user_bit32 AS ( 
select *,
(
  SELECT STRING_AGG(CAST(((activity_mask >> (31 - i)) & 1) AS STRING), '')
  FROM UNNEST(GENERATE_ARRAY(0, 31)) AS i
) AS binary_32bit,
 from bitmask
)
select *,
LENGTH(binary_32bit) - LENGTH(REPLACE(binary_32bit, '1', '')) AS bits_on_count,
BIT_COUNT(activity_mask) > 0 AS monthly_active,
BIT_COUNT(activity_mask & 4261412864) > 0 AS weekly_active,
(activity_mask & 2147483648) != 0 AS daily_active
 from total_user_bit32 





