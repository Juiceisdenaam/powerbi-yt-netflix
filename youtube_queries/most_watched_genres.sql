SELECT *
FROM (
    SELECT
        year_watched,
        video_genre,
        COUNT(*) AS views,
        ROUND(
            100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY year_watched),
            2
        ) AS genre_share_percent,
        RANK() OVER (
            PARTITION BY year_watched
            ORDER BY COUNT(*) DESC
        ) AS rank_per_year
    FROM
        date_time_fields
    GROUP BY
        year_watched,
        video_genre
) ranked_genres
WHERE
    rank_per_year <= 5
ORDER BY
    year_watched,
    rank_per_year;