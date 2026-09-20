-- ====================================================
-- 1. 起床報告 RPC
-- ====================================================
CREATE OR REPLACE FUNCTION public.report_wake_up(p_event_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_report public.event_reports%ROWTYPE;
    v_now TIMESTAMPTZ := NOW();
    v_is_late BOOLEAN := FALSE;
    v_new_status INT;
BEGIN
    -- レコード取得と行ロック（同時実行・連打対策）
    SELECT * INTO v_report
    FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report record not found for event % and user %', p_event_id, v_user_id;
    END IF;

    -- 二重打刻防止: 初期状態(0: sleeping)以外は打刻済みとみなして既存結果を返却
    IF v_report.actual_wakeup_time IS NOT NULL OR v_report.status <> 0 THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Already reported wake up',
            'status', v_report.status,
            'actual_wakeup_time', v_report.actual_wakeup_time,
            'is_late', (v_report.status = 2)
        );
    END IF;

    -- 目標起床時間との比較 (未設定時は遅刻なし判定)
    IF v_report.planned_wakeup_time IS NOT NULL AND v_now > v_report.planned_wakeup_time THEN
        v_is_late := TRUE;
        v_new_status := 2; -- overslept
        
        -- 通算寝坊回数をインクリメント
        UPDATE public.profiles
        SET sleep_past_count = sleep_past_count + 1, updated_at = v_now
        WHERE id = v_user_id;
    ELSE
        v_new_status := 1; -- awake
    END IF;

    -- レポートの更新
    UPDATE public.event_reports
    SET actual_wakeup_time = v_now,
        status = v_new_status,
        updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object(
        'success', true,
        'status', v_new_status,
        'actual_wakeup_time', v_now,
        'is_late', v_is_late
    );
END;
$$;


-- ====================================================
-- 2. 出発報告 RPC
-- ====================================================
CREATE OR REPLACE FUNCTION public.report_departure(p_event_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_report public.event_reports%ROWTYPE;
    v_now TIMESTAMPTZ := NOW();
BEGIN
    SELECT * INTO v_report
    FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report record not found';
    END IF;

    -- 二重打刻防止: すでに出発済み(3: moving)または到着済み(4, 5)の場合は既存結果を返却
    IF v_report.actual_departure_time IS NOT NULL OR v_report.status >= 3 THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Already reported departure',
            'status', v_report.status,
            'actual_departure_time', v_report.actual_departure_time
        );
    END IF;

    UPDATE public.event_reports
    SET actual_departure_time = v_now,
        status = 3, -- moving
        updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object(
        'success', true,
        'status', 3,
        'actual_departure_time', v_now
    );
END;
$$;


-- ====================================================
-- 3. QRコード到着チェックイン RPC
-- ====================================================
CREATE OR REPLACE FUNCTION public.check_in_by_qr(p_event_id UUID, p_qrcode TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_event public.events%ROWTYPE;
    v_report public.event_reports%ROWTYPE;
    v_now TIMESTAMPTZ := NOW();
    v_is_late BOOLEAN := FALSE;
    v_new_status INT;
BEGIN
    -- イベント取得
    SELECT * INTO v_event FROM public.events WHERE id = p_event_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Event not found';
    END IF;

    -- QRコード一致確認
    IF v_event.qrcode_id <> p_qrcode THEN
        RAISE EXCEPTION 'Invalid QR Code';
    END IF;

    -- レポート取得と行ロック
    SELECT * INTO v_report
    FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report record not found';
    END IF;

    -- 二重打刻防止: すでに到着済み(4: arrived, 5: late)の場合はカウント増加を行わず返却
    IF v_report.status IN (4, 5) THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Already checked in',
            'status', v_report.status,
            'is_late', (v_report.status = 5)
        );
    END IF;

    -- 集合時間超過判定
    IF v_now > v_event.arrival_time THEN
        v_is_late := TRUE;
        v_new_status := 5; -- late
        
        -- 通算遅刻回数をインクリメント
        UPDATE public.profiles
        SET late_count = late_count + 1, updated_at = v_now
        WHERE id = v_user_id;
    ELSE
        v_new_status := 4; -- arrived
    END IF;

    UPDATE public.event_reports
    SET status = v_new_status,
        updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object(
        'success', true,
        'status', v_new_status,
        'is_late', v_is_late
    );
END;
$$;


-- ====================================================
-- 4. パスコード到着チェックイン RPC
-- ====================================================
CREATE OR REPLACE FUNCTION public.check_in_by_passcode(p_event_id UUID, p_passcode TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_event public.events%ROWTYPE;
    v_report public.event_reports%ROWTYPE;
    v_now TIMESTAMPTZ := NOW();
    v_is_late BOOLEAN := FALSE;
    v_new_status INT;
BEGIN
    SELECT * INTO v_event FROM public.events WHERE id = p_event_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Event not found';
    END IF;

    IF v_event.password <> p_passcode THEN
        RAISE EXCEPTION 'Invalid Passcode';
    END IF;

    SELECT * INTO v_report
    FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report record not found';
    END IF;

    -- 二重打刻防止
    IF v_report.status IN (4, 5) THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Already checked in',
            'status', v_report.status,
            'is_late', (v_report.status = 5)
        );
    END IF;

    IF v_now > v_event.arrival_time THEN
        v_is_late := TRUE;
        v_new_status := 5; -- late
        UPDATE public.profiles
        SET late_count = late_count + 1, updated_at = v_now
        WHERE id = v_user_id;
    ELSE
        v_new_status := 4; -- arrived
    END IF;

    UPDATE public.event_reports
    SET status = v_new_status,
        updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object(
        'success', true,
        'status', v_new_status,
        'is_late', v_is_late
    );
END;
$$;


-- ====================================================
-- 5. 実行権限の付与 (GRANT EXECUTE)
-- ====================================================
-- 認証済みユーザー(authenticated)のみに関数の実行を許可
GRANT EXECUTE ON FUNCTION public.report_wake_up(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.report_departure(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_in_by_qr(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_in_by_passcode(UUID, TEXT) TO authenticated;

-- 未ログインユーザー(anon)からの実行は明示的に剥奪
REVOKE EXECUTE ON FUNCTION public.report_wake_up(UUID) FROM anon;
REVOKE EXECUTE ON FUNCTION public.report_departure(UUID) FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_in_by_qr(UUID, TEXT) FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_in_by_passcode(UUID, TEXT) FROM anon;