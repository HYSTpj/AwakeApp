-- ====================================================
-- 0. 拡張機能の有効化
-- ====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ====================================================
-- 1. profiles テーブル (auth.users と 1:1)
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

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 認証済みユーザーなら全員参照可能
CREATE POLICY "Profiles are readable by authenticated users"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

-- サインアップ時に自分のプロフィールを作成可能
CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- 自分のプロフィールのみ更新可能
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);


-- ====================================================
-- 2. groups テーブル
-- ====================================================
CREATE TABLE public.groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invitation_code TEXT UNIQUE NOT NULL,
    group_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;

-- 所属しているグループのみ閲覧可能
CREATE POLICY "Users can view groups they belong to"
    ON public.groups FOR SELECT
    TO authenticated
    USING (
        id IN (
            SELECT gm.group_id FROM public.groups_memberships gm WHERE gm.user_id = auth.uid()
        )
    );

-- 認証済みユーザーなら誰でも新規グループ作成可能
CREATE POLICY "Authenticated users can create groups"
    ON public.groups FOR INSERT
    TO authenticated
    WITH CHECK (true);


-- ====================================================
-- 3. groups_memberships テーブル (中間テーブル)
-- ====================================================
CREATE TABLE public.groups_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role INT NOT NULL DEFAULT 1 CHECK (role IN (0, 1)), -- 0: admin, 1: member
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_group_user UNIQUE (group_id, user_id)
);

ALTER TABLE public.groups_memberships ENABLE ROW LEVEL SECURITY;

-- 自分が所属しているグループのメンバー一覧のみ閲覧可能
CREATE POLICY "Members can view membership in their groups"
    ON public.groups_memberships FOR SELECT
    TO authenticated
    USING (
        group_id IN (
            SELECT gm.group_id FROM public.groups_memberships gm WHERE gm.user_id = auth.uid()
        )
    );

-- 自分自身をメンバーとしてグループに追加可能
CREATE POLICY "Users can join groups as themselves"
    ON public.groups_memberships FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- 自分が脱退する、または管理者が他メンバーを削除可能
CREATE POLICY "Users can leave group or admin can remove"
    ON public.groups_memberships FOR DELETE
    TO authenticated
    USING (
        auth.uid() = user_id
        OR EXISTS (
            SELECT 1 FROM public.groups_memberships gm
            WHERE gm.group_id = groups_memberships.group_id
                AND gm.user_id = auth.uid()
                AND gm.role = 0 -- 0: admin
        )
    );


-- ====================================================
-- 4. events テーブル
-- ====================================================
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    destination_name TEXT NOT NULL,
    location POINT,
    qrcode_id TEXT NOT NULL,
    password TEXT NOT NULL,
    arrival_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    update_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- 同一グループのメンバーのみイベントを閲覧可能
CREATE POLICY "Members can view group events"
    ON public.events FOR SELECT
    TO authenticated
    USING (
        group_id IN (
            SELECT gm.group_id FROM public.groups_memberships gm WHERE gm.user_id = auth.uid()
        )
    );

-- 所属グループの管理者（role = 0）のみイベントを作成可能
CREATE POLICY "Admins can create events"
    ON public.events FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.groups_memberships gm
            WHERE gm.group_id = events.group_id
                AND gm.user_id = auth.uid()
                AND gm.role = 0 -- 0: admin
        )
    );


-- ====================================================
-- 5. event_reports テーブル
-- ====================================================
CREATE TABLE public.event_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    planned_wakeup_time TIMESTAMPTZ,
    planned_departure_time TIMESTAMPTZ,
    actual_wakeup_time TIMESTAMPTZ,
    actual_departure_time TIMESTAMPTZ,
    status INT NOT NULL DEFAULT 0 CHECK (status BETWEEN 0 AND 5),
    -- 0: sleeping, 1: awake, 2: overslept, 3: moving, 4: arrived, 5: late
    late_reason TEXT,
    photo_url TEXT,
    location POINT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_event_user UNIQUE (event_id, user_id)
);

ALTER TABLE public.event_reports ENABLE ROW LEVEL SECURITY;

-- 同一イベントの参加者のみ全員のレポートを閲覧可能
CREATE POLICY "Participants can view event reports"
    ON public.event_reports FOR SELECT
    TO authenticated
    USING (
        event_id IN (
            SELECT e.id FROM public.events e
            JOIN public.groups_memberships gm ON gm.group_id = e.group_id
            WHERE gm.user_id = auth.uid()
        )
    );

-- イベント参加者が自分自身のレポート初期枠を作成可能
CREATE POLICY "Users can create their own event report"
    ON public.event_reports FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = user_id
        AND EXISTS (
            SELECT 1 FROM public.events e
            JOIN public.groups_memberships gm ON gm.group_id = e.group_id
            WHERE e.id = event_reports.event_id
                AND gm.user_id = auth.uid()
        )
    );

-- 予定時間の設定や遅刻理由の更新は本人のみ可能
CREATE POLICY "Users can update own planned times and excuses"
    ON public.event_reports FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());


-- ====================================================
-- 6. Realtime の有効化
-- ====================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.event_reports;