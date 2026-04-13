-- The Total Sum of all duration for all users = 19:09:42

SELECT date_format(from_unixtime(SUM(unix_timestamp(`Duration 2`))), 'HH:mm:ss') AS total_duration
FROM workspace.default.brighttv AS Viewers
LEFT JOIN `workspace`.`default`.`brighttv_up` AS UserPro
ON Viewers.UserID0 = UserPro.UserID;

-- The Total number of channels watched by all users = 21

SELECT COUNT(DISTINCT Channel2) AS total_channels
FROM workspace.default.brighttv AS Viewers
LEFT JOIN `workspace`.`default`.`brighttv_up` AS UserPro
ON Viewers.UserID0 = UserPro.UserID;

-- The Total number of users = 4386

SELECT COUNT(DISTINCT UserID0) AS total_users
FROM workspace.default.brighttv AS Viewers
LEFT JOIN `workspace`.`default`.`brighttv_up` AS UserPro
ON Viewers.UserID0 = UserPro.UserID;

-- Avarage Duration = 9 minutes 9 seconds

SELECT date_format(from_unixtime(AVG(unix_timestamp(`Duration 2`))), 'HH:mm:ss') AS avg_duration
FROM workspace.default.brighttv AS Viewers
LEFT JOIN `workspace`.`default`.`brighttv_up` AS UserPro
ON Viewers.UserID0 = UserPro.UserID;

-- Count number of users per show on chanel2 in descending order 

select channel2 AS Channel, 
Count(distinct Viewers.UserID0) AS NUM_Users
FROM workspace.default.brighttv AS Viewers
LEFT JOIN `workspace`.`default`.`brighttv_up` AS UserPro
ON Viewers.UserID0 = UserPro.UserID
GROUP BY Channel2
ORDER BY NUM_Users DESC;

-- Count number of Males and Females in the data set 

SELECT Gender, COUNT(*) AS Count
FROM `workspace`.`default`.`brighttv_up`
GROUP BY Gender;

-- Big Query processing for final outcomes

SELECT 
    ROW_NUMBER() OVER (ORDER BY Viewers.UserID0, Viewers.RecordDate2) AS session_id,
    Viewers.UserID0 AS subscriber_id,
    Viewers.Channel2 AS channel,
    from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg') AS session_start_sast,

    date_format(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg'), 'yyyy-MM-dd') AS session_date_sast,
    date_format(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg'), 'EEEE') AS day_of_week_name,  
    dayofweek(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) AS day_of_week_number,    
    hour(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) AS hour_of_day,
    weekofyear(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) AS week_of_year,
    month(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) AS month_number,
    date_format(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg'), 'MMMM') AS month_name,


    date_format(Viewers.`Duration 2`, 'HH:mm:ss') AS duration_original,
    (CAST(split(date_format(Viewers.`Duration 2`, 'HH:mm:ss'), ':')[0] AS INT) * 60) +
     CAST(split(date_format(Viewers.`Duration 2`, 'HH:mm:ss'), ':')[1] AS INT) +
     (CAST(split(date_format(Viewers.`Duration 2`, 'HH:mm:ss'), ':')[2] AS DOUBLE) / 60.0) AS duration_minutes,

    CASE
        WHEN hour(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) BETWEEN 0 AND 5 THEN 'Mid_Night'
        WHEN hour(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN hour(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN hour(from_utc_timestamp(Viewers.RecordDate2, 'Africa/Johannesburg')) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Unknown'
    END AS Time_Slot,

    COALESCE(UserPro.Gender, 'Unknown') AS gender,
    COALESCE(UserPro.Race, 'Unknown') AS race,
    UserPro.Age,
    CASE 
        WHEN UserPro.Age IS NULL OR UserPro.Age = 0 THEN 'Unknown'
        WHEN UserPro.Age < 18 THEN 'Under 18'
        WHEN UserPro.Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN UserPro.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN UserPro.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN UserPro.Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+' 
    END AS age_group,
    COALESCE(UserPro.Province, 'Unknown') AS province,
    COALESCE(UserPro.`Social Media Handle`, 'None') AS social_media_handle,

    UserPro.Name,
    UserPro.Surname,
    UserPro.Email

FROM workspace.default.brighttv AS Viewers
LEFT JOIN `workspace`.`default`.`brighttv_up` AS UserPro
ON Viewers.UserID0 = UserPro.UserID  

WHERE Viewers.UserID0 IS NOT NULL 
  AND Viewers.`Duration 2` IS NOT NULL 
  AND date_format(Viewers.`Duration 2`, 'HH:mm:ss') != '00:00:00'  

ORDER BY session_date_sast, hour_of_day, subscriber_id;
