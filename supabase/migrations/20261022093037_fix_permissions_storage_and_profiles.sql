-- ====================================================
-- 1. 不要・過剰な権限の初期化 (REVOKE)
-- ====================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated;

-- schema 自体の利用権限
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- ====================================================
-- 2. アプリ機能に必要な最小限の権限付与 (GRANT)
-- ====================================================

-- profiles: 参照・作成・更新（削除は auth.users 連動 CASCADE のみ）
GRANT SELECT, INSERT, UPDATE ON TABLE public.profiles TO authenticated;

-- groups: 作成・参照・更新・削除（管理者削除に対応）
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.groups TO authenticated;

-- groups_memberships: 参加・退会・メンバー一覧
GRANT SELECT, INSERT, DELETE ON TABLE public.groups_memberships TO authenticated;

-- events: 作成・参照・更新・削除（管理者削除に対応）
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.events TO authenticated;

-- events_view: 一般メンバー用のイベント一覧取得
GRANT SELECT ON TABLE public.events_view TO authenticated;

-- event_secrets: 管理者のみアクセス（RLSで制御）
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.event_secrets TO authenticated;

-- event_reports: レポート作成・更新・参照
GRANT SELECT, INSERT, UPDATE ON TABLE public.event_reports TO authenticated;

-- バックエンド管理ロール (service_role) には全権限を付与
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;

-- ====================================================
-- 3. avatars バケット公開設定 & Storage RLS ポリシー
-- ====================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE
SET public = true;

DROP POLICY IF EXISTS "avatars_user_insert" ON storage.objects;
DROP POLICY IF EXISTS "avatars_user_update" ON storage.objects;
DROP POLICY IF EXISTS "avatars_select" ON storage.objects;

-- INSERT: 自身の UID ディレクトリ配下のみアップロード許可
CREATE POLICY "avatars_user_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars'
    AND (name LIKE (auth.uid()::text || '/%'))
);

-- UPDATE: upsert 実行時の更新許可
CREATE POLICY "avatars_user_update"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars'
    AND (name LIKE (auth.uid()::text || '/%'))
)
WITH CHECK (
    bucket_id = 'avatars'
    AND (name LIKE (auth.uid()::text || '/%'))
);

-- SELECT: プロフィール画像の全体公開読み取り
CREATE POLICY "avatars_select"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- ====================================================
-- 4. プロフィール自動生成トリガー & 欠損データ救済
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
        COALESCE(NULLIF(LEFT(TRIM(NEW.raw_user_meta_data->>'nickname'), 30), ''), 'No Name'),
        NEW.raw_user_meta_data->>'avatar_url',
        0, 0
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- profiles 未作成ユーザーの救済
INSERT INTO public.profiles (id, nickname, avatar_url, sleep_past_count, late_count)
SELECT 
    id,
    COALESCE(NULLIF(LEFT(TRIM(raw_user_meta_data->>'nickname'), 30), ''), 'No Name'),
    raw_user_meta_data->>'avatar_url',
    0,
    0
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles)
ON CONFLICT (id) DO NOTHING;

-- 自身の UID ディレクトリ配下の画像のみ削除を許可
DROP POLICY IF EXISTS "avatars_user_delete" ON storage.objects;
CREATE POLICY "avatars_user_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'avatars'
    AND (name LIKE (auth.uid()::text || '/%'))
);