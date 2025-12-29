WITH top5_channel_this_year AS (
    SELECT
        channel
    FROM
        date_time_fields
    WHERE
        year_watched = 2025
    GROUP BY
        channel
    ORDER BY
        SUM(video_duration_hours) DESC
    LIMIT 5
)
SELECT
    dtf.channel,
    dtf.year_watched,
    SUM(dtf.video_duration_hours) AS total_hours
FROM
    date_time_fields dtf
    JOIN top5_channel_this_year t5
        ON t5.channel = dtf.channel
GROUP BY
    dtf.channel,
    dtf.year_watched
ORDER BY
    dtf.channel,
    dtf.year_watched;