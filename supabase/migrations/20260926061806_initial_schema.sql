-- ====================================================
-- 0. 拡張機能
-- ====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ====================================================
-- 1. テーブル定義
-- ====================================================
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname TEXT NOT NULL,
    avatar_url TEXT,
    sleep_past_count INT NOT NULL DEFAULT 0,
    late_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invitation_code TEXT UNIQUE NOT NULL,
    group_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.groups_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role INT NOT NULL DEFAULT 1 CHECK (role IN (0, 1)), -- 0: admin, 1: member
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_group_user UNIQUE (group_id, user_id)
);

CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    destination_name TEXT NOT NULL,
    location POINT,
    arrival_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 秘密情報専用テーブル（RLSにより管理者以外絶対にアクセス不可）
CREATE TABLE public.event_secrets (
    event_id UUID PRIMARY KEY REFERENCES public.events(id) ON DELETE CASCADE,
    qrcode_id TEXT NOT NULL,
    password TEXT NOT NULL
);

CREATE TABLE public.event_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    planned_wakeup_time TIMESTAMPTZ,
    planned_departure_time TIMESTAMPTZ,
    actual_wakeup_time TIMESTAMPTZ,
    actual_departure_time TIMESTAMPTZ,
    status INT NOT NULL DEFAULT 0 CHECK (status BETWEEN 0 AND 5),
    late_reason TEXT,
    photo_url TEXT,
    location POINT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_event_user UNIQUE (event_id, user_id)
);

-- ====================================================
-- 2. ヘルパー関数
-- ====================================================
CREATE OR REPLACE FUNCTION public.get_my_group_ids()
RETURNS SETOF UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT group_id FROM public.groups_memberships WHERE user_id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.is_group_admin(p_group_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.groups_memberships
        WHERE group_id = p_group_id
            AND user_id = auth.uid()
            AND role = 0
    );
$$;

-- レポート存在だけでなく、該当グループに現在も所属しているかを検証
CREATE OR REPLACE FUNCTION public.is_event_participant(p_event_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 
        FROM public.event_reports er
        JOIN public.events e ON e.id = er.event_id
        JOIN public.groups_memberships gm ON gm.group_id = e.group_id AND gm.user_id = auth.uid()
        WHERE er.event_id = p_event_id
            AND er.user_id = auth.uid()
    );
$$;

-- イベントが属するグループの管理者かどうかを安全に判定するヘルパー
CREATE OR REPLACE FUNCTION public.is_event_admin(p_event_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.events e
        JOIN public.groups_memberships gm ON gm.group_id = e.group_id
        WHERE e.id = p_event_id
          AND gm.user_id = auth.uid()
          AND gm.role = 0
    );
$$;

CREATE OR REPLACE FUNCTION public.can_delete_membership(p_group_id UUID, p_target_user_id UUID, p_target_role INT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE
SET search_path = public
AS $$
DECLARE
    v_caller_id UUID := auth.uid();
    v_is_admin BOOLEAN;
    v_remaining_admin_count INT;
    v_dummy UUID;
BEGIN
    IF v_caller_id IS NULL THEN
        RETURN FALSE;
    END IF;

    IF p_target_user_id = v_caller_id AND p_target_role = 1 THEN
        RETURN TRUE;
    END IF;

    SELECT id INTO v_dummy FROM public.groups WHERE id = p_group_id FOR UPDATE;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM public.groups_memberships
        WHERE group_id = p_group_id AND user_id = v_caller_id AND role = 0
    ) INTO v_is_admin;

    IF v_is_admin AND p_target_user_id <> v_caller_id THEN
        IF p_target_role = 1 THEN
            RETURN TRUE;
        END IF;

        IF p_target_role = 0 THEN
            SELECT COUNT(*) INTO v_remaining_admin_count
            FROM public.groups_memberships
            WHERE group_id = p_group_id AND role = 0 AND user_id <> p_target_user_id;

            RETURN (v_remaining_admin_count >= 1);
        END IF;
    END IF;

    IF p_target_user_id = v_caller_id AND p_target_role = 0 THEN
        SELECT COUNT(*) INTO v_remaining_admin_count
        FROM public.groups_memberships
        WHERE group_id = p_group_id AND role = 0 AND user_id <> v_caller_id;

        RETURN (v_remaining_admin_count >= 1);
    END IF;

    RETURN FALSE;
END;
$$;

-- ====================================================
-- 3. 秘密情報隠蔽用 VIEW
-- ====================================================
CREATE OR REPLACE VIEW public.events_view
WITH (security_invoker = true)
AS
SELECT 
    id, group_id, title, destination_name, location,
    arrival_time, status, created_at, updated_at
FROM public.events
WHERE group_id IN (SELECT public.get_my_group_ids());

-- ====================================================
-- 4. RLS ポリシー
-- ====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_secrets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_reports ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY "profiles_select" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_update" ON public.profiles FOR UPDATE TO authenticated 
USING (auth.uid() = id) 
WITH CHECK (auth.uid() = id);

-- groups
CREATE POLICY "groups_select" ON public.groups FOR SELECT TO authenticated
USING (id IN (SELECT public.get_my_group_ids()));

CREATE POLICY "groups_admin_mod" ON public.groups FOR ALL TO authenticated
USING (public.is_group_admin(id))
WITH CHECK (public.is_group_admin(id));

-- groups_memberships
CREATE POLICY "gm_select" ON public.groups_memberships FOR SELECT TO authenticated
USING (group_id IN (SELECT public.get_my_group_ids()));

CREATE POLICY "gm_delete" ON public.groups_memberships FOR DELETE TO authenticated
USING (public.can_delete_membership(group_id, user_id, role));

-- events
CREATE POLICY "events_select" ON public.events FOR SELECT TO authenticated
USING (group_id IN (SELECT public.get_my_group_ids()));

CREATE POLICY "events_admin_mod" ON public.events FOR ALL TO authenticated
USING (public.is_group_admin(group_id))
WITH CHECK (public.is_group_admin(group_id));

-- event_secrets: グループ管理者のみアクセス可能
CREATE POLICY "event_secrets_admin_all" ON public.event_secrets FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM public.events e WHERE e.id = event_secrets.event_id AND public.is_group_admin(e.group_id)))
WITH CHECK (EXISTS (SELECT 1 FROM public.events e WHERE e.id = event_secrets.event_id AND public.is_group_admin(e.group_id)));

-- event_reports: 参加者本人、または対象イベントのグループ管理者に閲覧を許可
CREATE POLICY "er_select" ON public.event_reports FOR SELECT TO authenticated
USING (public.is_event_participant(event_id) OR public.is_event_admin(event_id));

CREATE POLICY "er_update" ON public.event_reports FOR UPDATE TO authenticated
USING (user_id = auth.uid() AND public.is_event_participant(event_id))
WITH CHECK (user_id = auth.uid() AND public.is_event_participant(event_id));

-- avatars: 自分の UID プレフィックスのフォルダ配下のみアップロード許可
CREATE POLICY "avatars_user_insert" ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- late-evidences: 認証済みユーザーならアップロード許可
CREATE POLICY "late_evidences_insert" ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'late-evidences');

-- ====================================================
-- 5. トリガー
-- ====================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, nickname, avatar_url, sleep_past_count, late_count)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nickname', 'No Name'),
        NEW.raw_user_meta_data->>'avatar_url',
        0, 0
    );
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.prevent_profile_score_tampering()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF current_setting('app.rpc_updating', true) IS DISTINCT FROM 'true' THEN
        IF NEW.sleep_past_count IS DISTINCT FROM OLD.sleep_past_count OR
           NEW.late_count IS DISTINCT FROM OLD.late_count THEN
            RAISE EXCEPTION 'sleep_past_count and late_count cannot be modified directly';
        END IF;
    END IF;
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_profile_score_tampering ON public.profiles;
CREATE TRIGGER trg_prevent_profile_score_tampering
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_profile_score_tampering();

CREATE OR REPLACE FUNCTION public.prevent_report_status_tampering()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR NEW.user_id IS DISTINCT FROM OLD.user_id THEN
        RAISE EXCEPTION 'Cannot transfer report to another event or user';
    END IF;

    IF current_setting('app.rpc_updating', true) IS DISTINCT FROM 'true' THEN
        IF NEW.status IS DISTINCT FROM OLD.status OR
           NEW.actual_wakeup_time IS DISTINCT FROM OLD.actual_wakeup_time OR
           NEW.actual_departure_time IS DISTINCT FROM OLD.actual_departure_time THEN
            RAISE EXCEPTION 'status and actual timestamps can only be modified via check-in RPCs';
        END IF;
    END IF;
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_report_status_tampering ON public.event_reports;
CREATE TRIGGER trg_prevent_report_status_tampering
    BEFORE UPDATE ON public.event_reports
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_report_status_tampering();

CREATE OR REPLACE FUNCTION public.get_my_event_report(p_event_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_report public.event_reports%ROWTYPE;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    IF NOT public.is_event_participant(p_event_id) THEN
        RETURN NULL;
    END IF;

    SELECT * INTO v_report FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN to_jsonb(v_report);
END;
$$;

-- ====================================================
-- 6. RPC 定義
-- ====================================================
CREATE OR REPLACE FUNCTION public.create_group_with_admin(p_group_name TEXT, p_invitation_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_group_id UUID;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    INSERT INTO public.groups (group_name, invitation_code)
    VALUES (p_group_name, p_invitation_code)
    RETURNING id INTO v_group_id;

    INSERT INTO public.groups_memberships (group_id, user_id, role)
    VALUES (v_group_id, v_user_id, 0);

    RETURN jsonb_build_object('success', true, 'group_id', v_group_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.join_group_by_code(p_invitation_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_group_id UUID;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    SELECT id INTO v_group_id FROM public.groups WHERE invitation_code = p_invitation_code;
    IF NOT FOUND THEN RETURN jsonb_build_object('success', false, 'message', 'Invalid code'); END IF;

    IF EXISTS (SELECT 1 FROM public.groups_memberships WHERE group_id = v_group_id AND user_id = v_user_id) THEN
        RETURN jsonb_build_object('success', true, 'message', 'Already member', 'group_id', v_group_id);
    END IF;

    INSERT INTO public.groups_memberships (group_id, user_id, role) VALUES (v_group_id, v_user_id, 1);
    RETURN jsonb_build_object('success', true, 'group_id', v_group_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.create_event_with_participants(
    p_group_id UUID, p_title TEXT, p_destination_name TEXT,
    p_latitude DOUBLE PRECISION, p_longitude DOUBLE PRECISION,
    p_qrcode_id TEXT, p_password TEXT, p_arrival_time TIMESTAMPTZ,
    p_participant_ids UUID[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_event_id UUID;
    v_pid UUID;
    v_point POINT := NULL;
    v_valid_member_count INT;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
    IF NOT public.is_group_admin(p_group_id) THEN RAISE EXCEPTION 'Only group admins can create events'; END IF;

    IF array_length(p_participant_ids, 1) > 0 THEN
        SELECT COUNT(DISTINCT user_id) INTO v_valid_member_count
        FROM public.groups_memberships
        WHERE group_id = p_group_id AND user_id = ANY(p_participant_ids);

        IF v_valid_member_count <> array_length(p_participant_ids, 1) THEN
            RAISE EXCEPTION 'One or more participant IDs do not belong to this group';
        END IF;
    END IF;

    IF p_latitude IS NOT NULL AND p_longitude IS NOT NULL THEN
        v_point := point(p_latitude, p_longitude);
    END IF;

    INSERT INTO public.events (group_id, title, destination_name, location, arrival_time)
    VALUES (p_group_id, p_title, p_destination_name, v_point, p_arrival_time)
    RETURNING id INTO v_event_id;

    INSERT INTO public.event_secrets (event_id, qrcode_id, password)
    VALUES (v_event_id, p_qrcode_id, p_password);

    IF array_length(p_participant_ids, 1) > 0 THEN
        FOREACH v_pid IN ARRAY p_participant_ids LOOP
            INSERT INTO public.event_reports (event_id, user_id, status)
            VALUES (v_event_id, v_pid, 0)
            ON CONFLICT (event_id, user_id) DO NOTHING;
        END LOOP;
    END IF;

    RETURN jsonb_build_object('success', true, 'event_id', v_event_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.get_admin_events(p_group_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
    v_caller_id UUID := auth.uid();
BEGIN
    IF v_caller_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    IF NOT public.is_group_admin(p_group_id) THEN
        RAISE EXCEPTION 'Only group admins can access this data';
    END IF;

    RETURN (
        SELECT COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'id', e.id,
                    'group_id', e.group_id,
                    'title', e.title,
                    'destination_name', e.destination_name,
                    'location', e.location,
                    'arrival_time', e.arrival_time,
                    'status', e.status,
                    'created_at', e.created_at,
                    'updated_at', e.updated_at,
                    'qrcode_id', s.qrcode_id,
                    'password', s.password
                ) ORDER BY e.arrival_time ASC
            ),
            '[]'::jsonb
        )
        FROM public.events e
        LEFT JOIN public.event_secrets s ON s.event_id = e.id
        WHERE e.group_id = p_group_id
    );
END;
$$;

CREATE OR REPLACE FUNCTION public.report_wake_up(p_event_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_report public.event_reports%ROWTYPE;
    v_event_status TEXT;
    v_now TIMESTAMPTZ := NOW();
    v_is_late BOOLEAN := FALSE;
    v_new_status INT;
BEGIN
    IF NOT public.is_event_participant(p_event_id) THEN
        RAISE EXCEPTION 'Not an active event participant';
    END IF;

    SELECT status INTO v_event_status 
    FROM public.events 
    WHERE id = p_event_id 
    FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Event not found'; END IF;
    IF v_event_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'Event is not active';
    END IF;

    SELECT * INTO v_report FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Report record not found'; END IF;

    IF v_report.actual_wakeup_time IS NOT NULL OR v_report.status <> 0 THEN
        RETURN jsonb_build_object('success', true, 'message', 'Already reported', 'status', v_report.status);
    END IF;

    PERFORM set_config('app.rpc_updating', 'true', true);

    IF v_report.planned_wakeup_time IS NOT NULL AND v_now > v_report.planned_wakeup_time THEN
        v_is_late := TRUE;
        v_new_status := 2;
        UPDATE public.profiles SET sleep_past_count = sleep_past_count + 1, updated_at = v_now WHERE id = v_user_id;
    ELSE
        v_new_status := 1;
    END IF;

    UPDATE public.event_reports
    SET actual_wakeup_time = v_now, status = v_new_status, updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object('success', true, 'status', v_new_status, 'is_late', v_is_late);
END;
$$;

CREATE OR REPLACE FUNCTION public.report_departure(p_event_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_report public.event_reports%ROWTYPE;
    v_event_status TEXT;
    v_now TIMESTAMPTZ := NOW();
BEGIN
    IF NOT public.is_event_participant(p_event_id) THEN
        RAISE EXCEPTION 'Not an active event participant';
    END IF;

    SELECT status INTO v_event_status 
    FROM public.events 
    WHERE id = p_event_id 
    FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Event not found'; END IF;
    IF v_event_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'Event is not active';
    END IF;

    SELECT * INTO v_report FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Report record not found'; END IF;

    IF v_report.actual_departure_time IS NOT NULL OR v_report.status >= 3 THEN
        RETURN jsonb_build_object('success', true, 'message', 'Already departed', 'status', v_report.status);
    END IF;

    PERFORM set_config('app.rpc_updating', 'true', true);

    UPDATE public.event_reports
    SET actual_departure_time = v_now, status = 3, updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object('success', true, 'status', 3);
END;
$$;

-- [P1解消] QRチェックイン: 秘密の qrcode_id との完全一致のみを検証（event_idでの回避を廃止）
CREATE OR REPLACE FUNCTION public.check_in_by_qr(p_event_id UUID, p_qrcode TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_event_status TEXT;
    v_expected_qrcode TEXT;
    v_arrival_time TIMESTAMPTZ;
    v_report public.event_reports%ROWTYPE;
    v_now TIMESTAMPTZ := NOW();
    v_is_late BOOLEAN := FALSE;
    v_new_status INT;
BEGIN
    IF NOT public.is_event_participant(p_event_id) THEN
        RAISE EXCEPTION 'Not an active event participant';
    END IF;

    SELECT status, arrival_time INTO v_event_status, v_arrival_time
    FROM public.events 
    WHERE id = p_event_id 
    FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Event not found'; END IF;
    IF v_event_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'Event is not active';
    END IF;

    -- 秘密テーブルから qrcode_id を取得して完全一致を検証
    SELECT qrcode_id INTO v_expected_qrcode FROM public.event_secrets WHERE event_id = p_event_id;
    IF v_expected_qrcode IS DISTINCT FROM p_qrcode THEN
        RAISE EXCEPTION 'Invalid QR Code';
    END IF;

    SELECT * INTO v_report FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Report record not found'; END IF;
    IF v_report.status IN (4, 5) THEN
        RETURN jsonb_build_object('success', true, 'message', 'Already checked in', 'status', v_report.status);
    END IF;

    PERFORM set_config('app.rpc_updating', 'true', true);

    IF v_now > v_arrival_time THEN
        v_is_late := TRUE;
        v_new_status := 5;
        UPDATE public.profiles SET late_count = late_count + 1, updated_at = v_now WHERE id = v_user_id;
    ELSE
        v_new_status := 4;
    END IF;

    UPDATE public.event_reports
    SET status = v_new_status, updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object('success', true, 'status', v_new_status, 'is_late', v_is_late);
END;
$$;

-- パスコードチェックイン
CREATE OR REPLACE FUNCTION public.check_in_by_passcode(p_event_id UUID, p_passcode TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_event_status TEXT;
    v_expected_passcode TEXT;
    v_arrival_time TIMESTAMPTZ;
    v_report public.event_reports%ROWTYPE;
    v_now TIMESTAMPTZ := NOW();
    v_is_late BOOLEAN := FALSE;
    v_new_status INT;
BEGIN
    IF NOT public.is_event_participant(p_event_id) THEN
        RAISE EXCEPTION 'Not an active event participant';
    END IF;

    SELECT status, arrival_time INTO v_event_status, v_arrival_time
    FROM public.events 
    WHERE id = p_event_id 
    FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Event not found'; END IF;
    IF v_event_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'Event is not active';
    END IF;

    SELECT password INTO v_expected_passcode FROM public.event_secrets WHERE event_id = p_event_id;
    IF v_expected_passcode IS DISTINCT FROM p_passcode THEN
        RAISE EXCEPTION 'Invalid Passcode';
    END IF;

    SELECT * INTO v_report FROM public.event_reports
    WHERE event_id = p_event_id AND user_id = v_user_id FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Report record not found'; END IF;
    IF v_report.status IN (4, 5) THEN
        RETURN jsonb_build_object('success', true, 'message', 'Already checked in', 'status', v_report.status);
    END IF;

    PERFORM set_config('app.rpc_updating', 'true', true);

    IF v_now > v_arrival_time THEN
        v_is_late := TRUE;
        v_new_status := 5;
        UPDATE public.profiles SET late_count = late_count + 1, updated_at = v_now WHERE id = v_user_id;
    ELSE
        v_new_status := 4;
    END IF;

    UPDATE public.event_reports
    SET status = v_new_status, updated_at = v_now
    WHERE id = v_report.id;

    RETURN jsonb_build_object('success', true, 'status', v_new_status, 'is_late', v_is_late);
END;
$$;

-- ====================================================
-- 7. 権限設定 & Realtime
-- ====================================================
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_my_group_ids() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_group_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_event_participant(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_event_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_delete_membership(UUID, UUID, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_event_report(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_group_with_admin(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.join_group_by_code(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_event_with_participants(UUID, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION, TEXT, TEXT, TIMESTAMPTZ, UUID[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_events(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.report_wake_up(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.report_departure(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_in_by_qr(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_in_by_passcode(UUID, TEXT) TO authenticated;

-- Realtime 有効化
ALTER PUBLICATION supabase_realtime ADD TABLE public.events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.event_reports;