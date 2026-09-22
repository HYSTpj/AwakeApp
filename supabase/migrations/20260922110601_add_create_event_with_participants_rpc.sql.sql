-- ====================================================
-- イベント作成 & 参加者レポート一括作成 RPC
-- ====================================================
CREATE OR REPLACE FUNCTION public.create_event_with_participants(
    p_group_id UUID,
    p_title TEXT,
    p_destination_name TEXT,
    p_latitude DOUBLE PRECISION,
    p_longitude DOUBLE PRECISION,
    p_qrcode_id TEXT,
    p_password TEXT,
    p_arrival_time TIMESTAMPTZ,
    p_participant_ids UUID[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_role INT;
    v_event_id UUID;
    v_pid UUID;
    v_point POINT := NULL;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- 実行ユーザーがグループの管理者 (role = 0) か検証
    SELECT role INTO v_role
    FROM public.groups_memberships
    WHERE group_id = p_group_id AND user_id = v_user_id;

    IF v_role IS NULL OR v_role <> 0 THEN
        RAISE EXCEPTION 'Only group admins can create events';
    END IF;

    IF p_latitude IS NOT NULL AND p_longitude IS NOT NULL THEN
        v_point := point(p_latitude, p_longitude);
    END IF;

    -- 1. events レコード作成
    INSERT INTO public.events (
        group_id,
        title,
        destination_name,
        location,
        qrcode_id,
        password,
        arrival_time,
        status
    ) VALUES (
        p_group_id,
        p_title,
        p_destination_name,
        v_point,
        p_qrcode_id,
        p_password,
        p_arrival_time,
        'active'
    ) RETURNING id INTO v_event_id;

    -- 2. 選択された参加者全員の event_reports 初期レコードを一括生成 (status = 0: sleeping)
    IF array_length(p_participant_ids, 1) > 0 THEN
        FOREACH v_pid IN ARRAY p_participant_ids
        LOOP
            -- 該当ユーザーがグループに実在するか確認した上で挿入
            IF EXISTS (SELECT 1 FROM public.groups_memberships WHERE group_id = p_group_id AND user_id = v_pid) THEN
                INSERT INTO public.event_reports (
                    event_id,
                    user_id,
                    status
                ) VALUES (
                    v_event_id,
                    v_pid,
                    0
                ) ON CONFLICT (event_id, user_id) DO NOTHING;
            END IF;
        END LOOP;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'event_id', v_event_id
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_event_with_participants(UUID, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION, TEXT, TEXT, TIMESTAMPTZ, UUID[]) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.create_event_with_participants(UUID, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION, TEXT, TEXT, TIMESTAMPTZ, UUID[]) FROM anon;