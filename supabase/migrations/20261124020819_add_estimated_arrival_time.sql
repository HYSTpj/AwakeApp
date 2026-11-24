-- 遅刻報告画面で選択する「到着予定」時刻を event_reports に保存できるようにする

ALTER TABLE public.event_reports
  ADD COLUMN estimated_arrival_time TIMESTAMPTZ;

DROP FUNCTION IF EXISTS public.submit_late_report(UUID, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION);

CREATE FUNCTION public.submit_late_report(
    p_event_id UUID,
    p_reason TEXT,
    p_photo_url TEXT DEFAULT NULL,
    p_latitude DOUBLE PRECISION DEFAULT NULL,
    p_longitude DOUBLE PRECISION DEFAULT NULL,
    p_estimated_arrival_time TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_point POINT := NULL;
    v_event_status TEXT;
    v_current_status INT;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    -- 現在もグループの参加者であるかを検証
    IF NOT public.is_event_participant(p_event_id) THEN
        RAISE EXCEPTION 'Not an active event participant';
    END IF;

    -- イベントがアクティブか検証
    SELECT status INTO v_event_status
    FROM public.events
    WHERE id = p_event_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Event not found';
    END IF;
    IF v_event_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'Event is not active';
    END IF;

    -- 現在のレポート状態を確認
    SELECT status INTO v_current_status
    FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report record not found';
    END IF;

    -- すでに到着済み（4: 通常到着, 5: 遅刻到着）の場合は巻き戻し不可
    IF v_current_status IN (4, 5) THEN
        RAISE EXCEPTION 'Already checked in';
    END IF;

    IF p_latitude IS NOT NULL AND p_longitude IS NOT NULL THEN
        v_point := point(p_latitude, p_longitude);
    END IF;

    -- トリガーのチェックをパスするためのフラグ設定
    PERFORM set_config('app.rpc_updating', 'true', true);

    -- 到着前の場合のみ遅刻理由を記録し、ステータスが未起床(0)や起床(1)なら 2 (寝坊/遅刻) に更新
    -- 移動中(3)なら移動中ステータスを維持
    UPDATE public.event_reports
    SET
        late_reason = p_reason,
        photo_url = COALESCE(p_photo_url, photo_url),
        location = COALESCE(v_point, location),
        estimated_arrival_time = COALESCE(p_estimated_arrival_time, estimated_arrival_time),
        status = CASE WHEN v_current_status < 3 THEN 2 ELSE v_current_status END,
        updated_at = NOW()
    WHERE event_id = p_event_id
        AND user_id = v_user_id;

    RETURN jsonb_build_object('success', true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_late_report(UUID, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMPTZ) TO authenticated;
