WITH top_videos AS (
    SELECT 
        video_title, 
        url
    FROM 
        date_time_fields
    GROUP BY 
        video_title,
        url
    ORDER BY 
        COUNT(1) DESC
    LIMIT 5
)

-- Aggregate views per year for those videos
SELECT
    tv.video_title,
    COUNT(CASE WHEN year_watched = 2016 THEN 1 END) AS views_2016,
    COUNT(CASE WHEN year_watched = 2017 THEN 1 END) AS views_2017,
    COUNT(CASE WHEN year_watched = 2018 THEN 1 END) AS views_2018,
    COUNT(CASE WHEN year_watched = 2019 THEN 1 END) AS views_2019,
    COUNT(CASE WHEN year_watched = 2020 THEN 1 END) AS views_2020,
    COUNT(CASE WHEN year_watched = 2021 THEN 1 END) AS views_2021,
    COUNT(CASE WHEN year_watched = 2022 THEN 1 END) AS views_2022,
    COUNT(CASE WHEN year_watched = 2023 THEN 1 END) AS views_2023,
    COUNT(CASE WHEN year_watched = 2024 THEN 1 END) AS views_2024,
    COUNT(CASE WHEN year_watched = 2025 THEN 1 END) AS views_2025
FROM
    date_time_fields df
JOIN
    top_videos tv ON df.url = tv .url
GROUP BY
    tv.video_title