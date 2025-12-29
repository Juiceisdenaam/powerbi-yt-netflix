SELECT
    COUNT(1) AS videos_watched,
    SUM(video_duration_hours) AS total_hours,
    MIN(begin_timestamp_watched) AS first_video_watched,
    MAX(end_timestamp_watched) AS last_video_watched,
    FLOOR(DATEDIFF(DAY, MIN(begin_timestamp_watched), MAX(begin_timestamp_watched)) / 365)::INT || 'y' ||
    FLOOR((DATEDIFF(DAY, MIN(begin_timestamp_watched), MAX(begin_timestamp_watched)) % 365) / 30)::INT || 'm' ||
    ((DATEDIFF(DAY, MIN(begin_timestamp_watched), MAX(begin_timestamp_watched)) % 365) % 30)::INT || 'd' AS duration,
    COUNT(1)::FLOAT / NULLIF(DATEDIFF(DAY, MIN(begin_timestamp_watched), MAX(begin_timestamp_watched)), 0) AS avg_videos_per_day,
    (EXTRACT(EPOCH FROM SUM(video_duration)) / 60)::FLOAT / NULLIF(DATEDIFF(DAY, MIN(begin_timestamp_watched), MAX(begin_timestamp_watched)), 0) AS avg_minutes_per_day
FROM
    date_time_fields;