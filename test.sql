WITH base AS (
    SELECT
        *,
        TO_TIMESTAMP(SPLIT_PART(watch.timestamp, '+', 1), 'YYYY-MM-DD HH24:MI:SS.MS') AS full_timestamp,
        full_timestamp + duration::interval as end_timestamp
    FROM sandbox_frost.justin_van_gemeren_vir.watch_history watch
    LEFT JOIN sandbox_frost.justin_van_gemeren_vir.info info on watch.title_url = info.url
),
    dates AS (
        SELECT
            *,
            CAST(TO_TIMESTAMP(SPLIT_PART(full_timestamp, '+', 1), 'YYYY-MM-DD HH24:MI:SS.MS') AS DATE) AS datefield,
            TO_CHAR(TO_TIMESTAMP(SPLIT_PART(full_timestamp, '+', 1), 'YYYY-MM-DD HH24:MI:SS.MS'), 'HH24:MI:SS') AS timefield
        FROM base
),
    session AS (
        SELECT
            *,
            LAG(full_timestamp) OVER (ORDER BY full_timestamp) AS prev_timestamp
        FROM dates
        ORDER BY full_timestamp desc
), session_flags AS (
    SELECT
    *,
    DATEDIFF(minute, prev_timestamp::TIMESTAMP, full_timestamp::TIMESTAMP) as diff_minutes,
    CASE
        WHEN diff_minutes > 30 THEN 1
        ELSE 0
    END AS new_session
FROM session
), session_ids AS (
    SELECT
        *,
        SUM(new_session) OVER (ORDER BY full_timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS session_id
  FROM session_flags
), with_last AS (
    SELECT
        *
        , ROW_NUMBER() over (PARTITION BY session_id ORDER BY full_timestamp DESC) as rn
    FROM session_ids
), session_bounds AS (
    SELECT
        session_id,
        MIN(full_timestamp) AS begin_timestamp_session,
        MAX(CASE WHEN rn = 1 THEN full_timestamp + COALESCE(duration::interval, '00:00:00'::interval) END) AS end_timestamp_session
    FROM with_last
    GROUP BY session_id
)



SELECT *, DATEDIFF(second, s.begin_timestamp_session::TIMESTAMP, s.end_timestamp_session::TIMESTAMP) as session_duration
from with_last w
JOIN session_bounds s using(session_id)
order by session_duration desc
