WITH base AS (
    SELECT
        history.title_url AS url,
        (history.timestamp::timestamptz AT TIME ZONE 'Europe/Amsterdam')::TIMESTAMP AS begin_timestamp_watched,
        info.duration::INTERVAL AS video_duration,
        begin_timestamp_watched + video_duration AS end_timestamp_watched,
        info.published_at::TIMESTAMP AS published_at,
        info.channel,
        info.title AS video_title,
        info.views AS amount_views,
        info.likes AS amount_likes,
        info.genres AS video_genre,
        info.comments AS amount_comments,
        info.channel_subscribers AS amount_channel_subscribers
    FROM projects.youtube.watch_history history
    LEFT JOIN projects.youtube.info info on history.title_url = info.url
)
    SELECT
        *,
        EXTRACT(YEAR FROM begin_timestamp_watched) AS year_watched,
        EXTRACT(MONTH FROM begin_timestamp_watched) AS month_watched,
        TO_CHAR(begin_timestamp_watched, 'Month') as month_watched_text,
        EXTRACT(WEEK FROM begin_timestamp_watched) AS week_watched,
        EXTRACT(DOW FROM begin_timestamp_watched) AS day_of_week_watched,
        TO_CHAR(begin_timestamp_watched, 'Day') AS day_of_week_watched_text,
        CASE
            WHEN day_of_week_watched IN (6, 7) THEN 1
            ELSE 0
        END AS weekend_indicator_watched,
        TO_CHAR(begin_timestamp_watched,'IYYYIW') AS year_week_key,
        TO_CHAR(begin_timestamp_watched,'IYYY"-"IW') AS year_week_label,
        EXTRACT(HOUR FROM begin_timestamp_watched) AS hour_of_day_watched
    FROM base



