ALTER TABLE public.event_reports
ADD COLUMN IF NOT EXISTS checked_in_at TIMESTAMPTZ;

-- Legacy reports have no dedicated check-in timestamp, so updated_at is the best available value.
-- The guard trigger advances updated_at on every update, so disable it during backfill.
ALTER TABLE public.event_reports
DISABLE TRIGGER trg_prevent_report_status_tampering;

UPDATE public.event_reports
SET checked_in_at = updated_at
WHERE status IN (4, 5)
  AND checked_in_at IS NULL;

ALTER TABLE public.event_reports
ENABLE TRIGGER trg_prevent_report_status_tampering;

CREATE OR REPLACE FUNCTION public.set_event_report_checked_in_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
    IF OLD.status NOT IN (4, 5) AND NEW.status IN (4, 5) THEN
        NEW.checked_in_at := COALESCE(NEW.checked_in_at, NEW.updated_at, NOW());
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_event_report_checked_in_at ON public.event_reports;
CREATE TRIGGER trg_set_event_report_checked_in_at
    BEFORE UPDATE OF status ON public.event_reports
    FOR EACH ROW
    EXECUTE FUNCTION public.set_event_report_checked_in_at();

CREATE OR REPLACE FUNCTION public.get_group_rankings(p_group_id UUID)
RETURNS TABLE (
    id UUID,
    nickname TEXT,
    avatar_url TEXT,
    streak INTEGER,
    total_delay_minutes INTEGER,
    avg_delay_minutes INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.groups_memberships gm
        WHERE gm.group_id = p_group_id
          AND gm.user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Not a group member';
    END IF;

    RETURN QUERY
    WITH group_members AS (
        SELECT p.id, p.nickname, p.avatar_url
        FROM public.groups_memberships gm
        JOIN public.profiles p ON p.id = gm.user_id
        WHERE gm.group_id = p_group_id
    ),
    ordered_reports AS (
        SELECT
            er.user_id,
            er.status,
            er.checked_in_at,
            e.arrival_time,
            ROW_NUMBER() OVER (
                PARTITION BY er.user_id
                ORDER BY e.arrival_time DESC, e.id DESC
            ) AS event_order
        FROM public.event_reports er
        JOIN public.events e ON e.id = er.event_id
        WHERE e.group_id = p_group_id
          AND e.status = 'completed'
    ),
    streak_breaks AS (
        SELECT
            user_id,
            MIN(event_order) FILTER (
                WHERE status <> 4 OR checked_in_at IS NULL
            ) AS first_break
        FROM ordered_reports
        GROUP BY user_id
    ),
    streaks AS (
        SELECT
            r.user_id,
            COUNT(*) FILTER (
                WHERE r.status = 4
                  AND r.checked_in_at IS NOT NULL
                  AND (b.first_break IS NULL OR r.event_order < b.first_break)
            )::INTEGER AS current_streak
        FROM ordered_reports r
        JOIN streak_breaks b ON b.user_id = r.user_id
        GROUP BY r.user_id
    ),
    delay_totals AS (
        SELECT
            user_id,
            SUM(
                GREATEST(
                    EXTRACT(EPOCH FROM (checked_in_at - arrival_time)) / 60.0,
                    0.0
                )
            ) FILTER (
                WHERE status IN (4, 5) AND checked_in_at IS NOT NULL
            ) AS total_minutes,
            COUNT(*) FILTER (
                WHERE status IN (4, 5) AND checked_in_at IS NOT NULL
            ) AS checked_in_count
        FROM ordered_reports
        GROUP BY user_id
    ),
    metrics AS (
        SELECT
            user_id,
            COALESCE(ROUND(total_minutes), 0)::INTEGER AS total_delay_minutes,
            CASE
                WHEN checked_in_count = 0 THEN 0
                ELSE ROUND(total_minutes / checked_in_count)::INTEGER
            END AS avg_delay_minutes
        FROM delay_totals
    )
    SELECT
        gm.id,
        gm.nickname,
        gm.avatar_url,
        COALESCE(s.current_streak, 0)::INTEGER,
        COALESCE(m.total_delay_minutes, 0)::INTEGER,
        COALESCE(m.avg_delay_minutes, 0)::INTEGER
    FROM group_members gm
    LEFT JOIN streaks s ON s.user_id = gm.id
    LEFT JOIN metrics m ON m.user_id = gm.id
    ORDER BY COALESCE(m.total_delay_minutes, 0) DESC, gm.nickname ASC;
END;
$$;

REVOKE ALL ON FUNCTION public.get_group_rankings(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_group_rankings(UUID) TO authenticated;
