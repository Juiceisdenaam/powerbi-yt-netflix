SELECT *
FROM (
    SELECT
        year_watched,
        video_title,
        COUNT(*) AS views,
        RANK() OVER (
            PARTITION BY year_watched
            ORDER BY COUNT(*) DESC
        ) AS rank_per_year
    FROM
        date_time_fields
    GROUP BY
        year_watched,
        video_title,
        url
) ranked_videos
WHERE
    rank_per_year = 1
ORDER BY
    year_watched DESC,
    rank_per_year;