WITH ordered_views AS (
    SELECT
        *,
        LAG(end_timestamp_watched) OVER (ORDER BY begin_timestamp_watched) AS previous_end
    FROM
        date_time_fields
),
session_flags AS (
    SELECT
        *,
        CASE
            WHEN previous_end IS NULL THEN 1
            WHEN DATEDIFF(MINUTE, previous_end, begin_timestamp_watched) > 30 THEN 1
            ELSE 0
        END AS new_session_flag
    FROM
        ordered_views
),
session_ids AS (
    SELECT
        *,
        SUM(new_session_flag) OVER (
            ORDER BY begin_timestamp_watched
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS session_id
    FROM
        session_flags
),
last_video_per_session AS (
    SELECT
        session_id,
        MAX(begin_timestamp_watched) AS last_video_start
    FROM
        session_ids
    GROUP BY
        session_id
),
session_end_times AS (
    SELECT
        s.session_id,
        DATEADD(
            MINUTE,
            CAST(v.video_duration_minutes AS INT),
            s.last_video_start
        ) AS session_end
    FROM
        last_video_per_session s
        JOIN session_ids v
            ON s.session_id = v.session_id
            AND s.last_video_start = v.begin_timestamp_watched
),
session_summary AS (
    SELECT
        si.session_id,
        MIN(si.begin_timestamp_watched) AS session_start,
        se.session_end,
        COUNT(*) AS videos_watched,
        DATEDIFF(MINUTE, MIN(si.begin_timestamp_watched), se.session_end) AS session_duration_minutes
    FROM
        session_ids si
        JOIN session_end_times se
            ON si.session_id = se.session_id
    GROUP BY
        si.session_id,
        se.session_end
),
session_details AS (
    SELECT
        session_id,
        video_title,
        begin_timestamp_watched,
        video_duration_minutes
    FROM
        session_ids
)
SELECT
    CASE
        WHEN session_duration_minutes < 15 THEN ‘0-15 minutes’
        WHEN session_duration_minutes < 30 THEN ‘15-30 minutes’
        WHEN session_duration_minutes < 45 THEN ‘30-45 minutes’
        WHEN session_duration_minutes < 60 THEN ‘45-60 minutes’
        ELSE ‘60+ minutes’
    END AS duration_bucket,
    COUNT(1) AS session_count
FROM
    session_summary
GROUP BY
    1
ORDER BY
    1;