SELECT
    CASE
        WHEN EXTRACT(MONTH FROM begin_timestamp_watched) >= 7
            THEN CONCAT(
                EXTRACT(YEAR FROM begin_timestamp_watched),
                EXTRACT(YEAR FROM begin_timestamp_watched) + 1
            )
        ELSE CONCAT(
            EXTRACT(YEAR FROM begin_timestamp_watched) - 1,
            EXTRACT(YEAR FROM begin_timestamp_watched)
        )
    END AS season,
    ROUND(SUM(EXTRACT(EPOCH FROM video_duration)) / 3600, 2) AS total_hours_watched,
    COUNT(1) AS views
FROM
    date_time_fields
WHERE
    channel = 'AFC Ajax'
GROUP BY
    season
ORDER BY
    season;