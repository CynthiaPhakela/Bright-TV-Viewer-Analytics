-- User profile table with names, emails, demographics, and social handles. Enables 3 things: audience segmentation, targeted campaigns, and cross-platform engagement analysis.
----------------------------------------------------------------------------------------
--Wanted to see the whole table before doing analysis on it
SELECT *
FROM workspace.default.bright_tv_user_profiles
LIMIT 10;

-- Check size of dataset
SELECT COUNT (*) AS number_of_rows
FROM workspace.default.bright_tv_user_profiles;

-- Check number of subscribers
SELECT COUNT (*) AS nuber_of_rows,
COUNT (DISTINCT UserID) AS number_subs
FROM workspace.default.bright_tv_user_profiles;

-- to check duplicates in columns using GROUP  BY and HAVING to count dubplicates. Where HAVING filters out any any groups that appear more than once and leaves duplucates.
SELECT UserID, 
    COUNT(*) as appearance_count
FROM workspace.default.bright_tv_user_profiles
GROUP BY UserID
HAVING COUNT(*) > 1
ORDER BY appearance_count DESC;

-- check for duplicates
SELECT UserID, 
    COUNT(*) AS duplicate_count
FROM workspace.default.bright_tv_user_profiles
GROUP BY UserID
HAVING COUNT(*) > 1;
----------------------------------------------------------------------------------------------

--to check if UserID IS NULL or empty in any rows
SELECT COUNT (*) AS cnt
FROM workspace.default.bright_tv_user_profiles
WHERE UserID IS NULL;
-----------------------------------------------------------------------------------------
--Gender Checks
---------------------------------------------------------------------------------------
--Check how many genders are found in the gender column
SELECT DISTINCt gender
FROM workspace.default.bright_tv_user_profiles;

-- Check if Gender column has any NULL values
SELECT COUNT(*) as number_rows
FROM  workspace.default.bright_tv_user_profiles
WHERE Gender IS NULL

-- check empty spaces in gender column; found 218
SELECT COUNT(*) 
FROM workspace.default.bright_tv_user_profiles
WHERE gender=' ';

-- Amend Blank values to None in gender column
SELECT
    COUNT (DISTINCT UserID) AS subs,
CASE 
    WHEN gender= ' ' THEN 'None'
    ELSE gender
END AS Gender
FROM workspace.default.bright_tv_user_profiles
GROUP BY Gender;
-------------------------------------------------------------------------------------
-- Race Checks
------------------------------------------------------------------------------------

-- Gives White, black, Coloured, other, none, indian_asian an bank spaces
SELECT DISTINCT Race
FROM workspace.default.bright_tv_user_profiles

-- to check if there are any rows where race IS NULL 
SELECT COUNT(*) as number_rows
FROM  workspace.default.bright_tv_user_profiles
WHERE Race IS NULL 

-- amend black values and other value on Race tocumn to None
SELECT DISTINCT
CASE
    WHEN Race= 'other' THEN 'None'
    WHEN Race= ' ' THEN 'None'
    ELSE Race
    END AS Race
FROM workspace.default.bright_tv_user_profiles;

--------------------------------------------------------------------------
--Province Checks
-------------------------------------------------------------------------

-- Check Provinces represented in the dataset. Picked up None and Blank values in he column
SELECT DISTINCT Province
FROM workspace.default.bright_tv_user_profiles

-- to check if any rows have NULL values in the column
SELECT COUNT(*) as number_rows
FROM  workspace.default.bright_tv_user_profiles
WHERE Province IS NULL 

-- replaced None and blanck values to Uncategorised category in the Provice column
SELECT DISTINCT
CASE
    WHEN Province= ' ' THEN 'Uncategorised'
    WHEN Province= 'None' THEN 'Uncategorised'
    ELSE Province
    END AS Region
FROM workspace.default.bright_tv_user_profiles;

------------------------------------------------------
--Age Checks
-----------------------------------------------------
--Check youngest and oldest viewer ages
SELECT MIN(Age) AS min_age, -- o years
        MAX(Age) AS max_age -- 114 years
FROM workspace.default.bright_tv_user_profiles;

-- Check if age IS NULL in the AGE column
SELECT COUNT(*) AS cnt
FROM workspace.default.bright_tv_user_profiles
WHERE age IS NULL;

-- Created Age Buckets
SELECT COUNT (DISTINCT UserID)AS subs,
CASE
    WHEN age = 0 THEN 'Infants'
    WHEN age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN age BETWEEN 13 AND 19 THEN 'Teens'
    WHEN age BETWEEN 20 AND 35 THEN 'Youth'
    WHEN age BETWEEN 36 AND 50 THEN 'Adults'
    WHEN age BETWEEN 51 AND 65 THEN 'Seniors'
    WHEN age > 65 THEN 'Pensioners'
    END AS age_groups
FROM workspace.default.bright_tv_user_profiles
GROUP BY age_groups;
---------------------------------------------------------------------------
WITH cte1 AS (
SELECT UserID,
CASE
    WHEN Province= ' ' THEN 'Uncategorised'
    WHEN Province= 'None' THEN 'Uncategorised'
    ELSE Province
    END AS Region,
 CASE 
    WHEN gender= ' ' THEN 'None'
    ELSE gender
END AS Gender,   
age,
CASE
    WHEN age = 0 THEN 'Infants'
    WHEN age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN age BETWEEN 13 AND 19 THEN 'Teens'
    WHEN age BETWEEN 20 AND 35 THEN 'Youth'
    WHEN age BETWEEN 36 AND 50 THEN 'Adults'
    WHEN age BETWEEN 51 AND 65 THEN 'Seniors'
    WHEN age > 65 THEN 'Pensioners'
    END AS age_groups,
 CASE
    WHEN Race= 'other' THEN 'None'
    WHEN Race= ' ' THEN 'None'
    ELSE Race
    END AS Race,   
CASE
    WHEN (Email IS NOT NULL) OR (Email=' ') OR (Email NOT IN ('None')) THEN 1
    ELSE 0 
    END as email_flag,
CASE 
    WHEN `Social Media Handle` IS NOT NULL OR `Social Media Handle`=' ' OR 'Social Media' NOT IN ('NONE') THEN 1
    ELSE 0
    END AS sm_flag
 FROM workspace.default.bright_tv_user_profiles   
 ) 
SELECT*
FROM cte1;
================

-- Inspect columns in the viewership dataset
SELECT * 
FROM workspace.default.bright_tv_viewership
LIMIT 10;

-- to check the size of the data
SELECT COUNT (*) AS num_rows,
       COUNT(COALESCE(USERID0,userid4))AS subs
FROM workspace.default.bright_tv_viewership; 

--to count the number of active uses or users that are watching from the subscribers
SELECT COUNT (*) AS num_rows,
       COUNT(COALESCE(USERID0,userid4))AS active_subs,
       COUNT(DISTINCT COALESCE(USERID0,userid4))AS active_users --number of people using their subcription
FROM workspace.default.bright_tv_viewership; 

--to check number of programms on Channel2
SELECT DISTINCT Channel2
FROM workspace.default.bright_tv_viewership; 

-- combined dupicate tv programms on the Channel2 column
SELECT DISTINCT
    CASE    
        WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('SuperSport Live Events','Supersport Live Events','Live on SuperSport') THEN 'SuperSports Live Events'
ELSE Channel2
END AS TV_Channel
FROM workspace.default.bright_tv_viewership;



WITH base AS (
SELECT COALESCE(USERID0,userid4) AS userid
FROM workspace.default.bright_tv_viewership
),
processing AS (
SELECT 
        COALESCE(USERID0,userid4) AS userid,
        TO_CHAR (RecordDate2, 'yyyyMM') AS month_id,
        TO_DATE (RecordDate2) AS watch_date,
        MONTHNAME (RecordDate2) AS month_name,
        DAY (RecordDate2) AS day,
        DAYNAME (RecordDate2) AS day_name,
        DAYOFWEEK (RecordDate2) AS day_of_week,
CASE
        WHEN day_name IN ('Sat','Sun') THEN 'weekend'
        ELSE 'weekday'
        END AS day_classificatiom,
 
           date_format (RecordDate2, 'HH:mm:ss') As watch_time,
        HOUR (RecordDate2) AS hour_of_day,       
        date_format (`Duration 2`, 'HH:mm:ss') AS duration,       
CASE    
        WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('SuperSport Live Events','Supersport Live Events','Live on SuperSport') THEN 'SuperSports Live Events'
    ELSE Channel2
END AS TV_Channel
FROM workspace.default.bright_tv_viewership;
)

================================================================
--  BRIGHT TV — MASTER VIEW v2  
--  JOIN: Viewership LEFT JOIN User Profiles
--  Result: 10,000 rows (one per session)
--  25 columns including all derived metrics
-- ================================================================
CREATE OR REPLACE VIEW bright_tv_master_v2 AS

-- ── CTE 1: Clean User Profiles ──────────────────────────────────
WITH profiles AS (
  SELECT
    UserID,
    CASE WHEN Province IN (' ', 'None') OR Province IS NULL
         THEN 'Uncategorised'
         ELSE Province
    END                                                    AS Region,
    CASE WHEN gender = ' ' OR gender IS NULL
         THEN 'None'
         ELSE gender
    END                                                    AS Gender,
    age,
    CASE
      WHEN age = 0               THEN 'Infants'
      WHEN age BETWEEN 1  AND 12 THEN 'Kids'
      WHEN age BETWEEN 13 AND 19 THEN 'Teens'
      WHEN age BETWEEN 20 AND 35 THEN 'Youth'
      WHEN age BETWEEN 36 AND 50 THEN 'Adults'
      WHEN age BETWEEN 51 AND 65 THEN 'Seniors'
      WHEN age > 65              THEN 'Pensioners'
    END                                                    AS age_groups,
    CASE WHEN Race IN ('other', ' ') OR Race IS NULL
         THEN 'None'
         ELSE Race
    END                                                    AS Race,
    CASE WHEN Email IS NOT NULL
         AND Email NOT IN (' ', 'None') THEN 1
         ELSE 0
    END                                                    AS email_flag,
    CASE WHEN `Social Media Handle` IS NOT NULL
         AND `Social Media Handle` NOT IN (' ', 'None', 'NONE') THEN 1
         ELSE 0
    END                                                    AS sm_flag
  FROM workspace.default.bright_tv_user_profiles
),


-- ── CTE 2: Clean Viewership ──────────────────────────────────────
viewership AS (
  SELECT
    COALESCE(USERID0, userid4)             AS UserID,

    -- Date and time dimensions
    TO_CHAR(RecordDate2, 'yyyyMM')          AS month_id,
    TO_DATE(RecordDate2)                    AS watch_date,
    MONTHNAME(RecordDate2)                  AS month_name,
    DAY(RecordDate2)                        AS day,
    DAYNAME(RecordDate2)                    AS day_name,
    DAYOFWEEK(RecordDate2)                  AS day_of_week,
    WEEKOFYEAR(RecordDate2)                 AS week_of_year,
    CASE
      WHEN DAYNAME(RecordDate2) IN ('Sat', 'Sun') THEN 'weekend'
      ELSE 'weekday'
    END                                     AS day_type,
    date_format(RecordDate2, 'HH:mm:ss')   AS watch_time,
    HOUR(RecordDate2)                       AS hour_of_day,

    -- Duration formatted
    date_format(`Duration 2`, 'HH:mm:ss')  AS duration,

    -- Duration in seconds (enables numeric AVG/SUM)
    CAST(
      HOUR(TO_TIMESTAMP(
        date_format(`Duration 2`, 'HH:mm:ss'), 'HH:mm:ss')) * 3600 +
      MINUTE(TO_TIMESTAMP(
        date_format(`Duration 2`, 'HH:mm:ss'), 'HH:mm:ss')) * 60   +
      SECOND(TO_TIMESTAMP(
        date_format(`Duration 2`, 'HH:mm:ss'), 'HH:mm:ss'))
    AS INT)                                 AS duration_seconds,
    ROUND(HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60, 2) AS duration_minute,

    -- Bounce flag: session under 30 seconds = accidental / low-quality view
    CASE WHEN CAST(
      HOUR(TO_TIMESTAMP(
        date_format(`Duration 2`, 'HH:mm:ss'), 'HH:mm:ss')) * 3600 +
      MINUTE(TO_TIMESTAMP(
        date_format(`Duration 2`, 'HH:mm:ss'), 'HH:mm:ss')) * 60   +
      SECOND(TO_TIMESTAMP(
        date_format(`Duration 2`, 'HH:mm:ss'), 'HH:mm:ss'))
    AS INT) < 30 THEN 1 ELSE 0 END         AS bounce_flag,

    -- Standardised channel name
    CASE
      WHEN Channel2 IN ('SawSee', 'Sawsee')
           THEN 'SawSee'
      WHEN Channel2 IN ('SuperSport Live Events',
           'Supersport Live Events', 'Live on SuperSport')
           THEN 'SuperSports Live Events'
      ELSE Channel2
    END                                     AS TV_Channel,

    -- Content category grouping
    CASE
      WHEN Channel2 IN ('SuperSport Blitz', 'Supersport Live Events',
           'SuperSport Live Events', 'Live on SuperSport',
           'ICC Cricket World Cup 2011', 'Wimbledon')
           THEN 'Sports'
      WHEN Channel2 = 'DStv Events 1'      THEN 'Sports/Events'
      WHEN Channel2 IN ('Channel O', 'Trace TV', 'MK')
           THEN 'Music'
      WHEN Channel2 IN ('Africa Magic', 'M-Net', 'E! Entertainment',
           'Vuzu', 'SawSee', 'Sawsee')
           THEN 'Entertainment'
      WHEN Channel2 IN ('Cartoon Network', 'Boomerang')
           THEN 'Kids/Family'
      WHEN Channel2 = 'CNN'                THEN 'News'
      WHEN Channel2 = 'kykNET'             THEN 'Local/Afrikaans'
      ELSE 'Other'
    END                                     AS content_category

  FROM workspace.default.bright_tv_viewership
),

-- ── CTE 3: User-level session count for engagement tier ───────────
user_sessions AS (
  SELECT
    COALESCE(USERID0, userid4) AS UserID,
    COUNT(*)                   AS total_user_sessions
  FROM workspace.default.bright_tv_viewership
  GROUP BY COALESCE(USERID0, userid4)
)
-- ── FINAL SELECT: Viewership LEFT JOIN User Profiles ─────
-- Viewership is the LEFT (driving) table → always 10,000 rows
SELECT
  v.UserID,

  -- Profile fields (NULL where UserID not in User Profiles table)
  p.Region,
  p.Gender,
  p.age                                     AS Age,
  p.age_groups,
  p.Race,
  p.email_flag,
  p.sm_flag,

  -- Viewership fields
  v.TV_Channel,
  v.content_category,
  v.month_id,
  v.month_name,
  v.watch_date,
  v.day,
  v.day_name,
  v.day_of_week,
  v.week_of_year,
  v.day_type,
  v.watch_time,
  v.hour_of_day,
  v.duration,
  v.duration_minute,
  v.duration_seconds,
  v.bounce_flag,

  -- Engagement metrics
  us.total_user_sessions,
  CASE
    WHEN us.total_user_sessions > 10       THEN 'Power'
    WHEN us.total_user_sessions BETWEEN 6 AND 10 THEN 'Regular'
    WHEN us.total_user_sessions BETWEEN 2 AND 5  THEN 'Casual'
    WHEN us.total_user_sessions = 1        THEN 'One-Time'
    ELSE 'Unknown'
  END                                       AS engagement_tier

FROM      viewership    v
LEFT JOIN profiles      p  ON v.UserID = p.UserID
LEFT JOIN user_sessions us ON v.UserID = us.UserID;
