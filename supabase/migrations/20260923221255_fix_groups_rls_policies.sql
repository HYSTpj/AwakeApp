-- ==========================================
-- 1. groups_memberships の RLS ポリシー修正
-- ==========================================
DO $$
DECLARE
    pol record;
BEGIN
    FOR pol IN (SELECT policyname FROM pg_policies WHERE tablename = 'groups_memberships') LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON groups_memberships', pol.policyname);
    END LOOP;
END $$;

-- 自身が所属するグループID一覧を安全に取得する関数（循環参照防止）
CREATE OR REPLACE FUNCTION get_my_group_ids()
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT group_id FROM groups_memberships WHERE user_id = auth.uid();
$$;

-- メンバーシップの SELECT / INSERT / UPDATE / DELETE
CREATE POLICY "gm_select_authenticated"
ON groups_memberships FOR SELECT
TO authenticated
USING (
    user_id = auth.uid()
);

CREATE POLICY "gm_insert_policy"
ON groups_memberships FOR INSERT
TO authenticated
WITH CHECK (
    user_id = auth.uid()
);

CREATE POLICY "gm_update_policy"
ON groups_memberships FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "gm_delete_policy"
ON groups_memberships FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- ==========================================
-- 2. groups の RLS ポリシー修正
-- ==========================================
DO $$
DECLARE
    pol record;
BEGIN
    FOR pol IN (SELECT policyname FROM pg_policies WHERE tablename = 'groups') LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON groups', pol.policyname);
    END LOOP;
END $$;

-- 作成: 認証済みユーザーなら作成可能
CREATE POLICY "groups_insert_all_auth"
ON groups FOR INSERT
TO authenticated
WITH CHECK (true);

-- 閲覧: 作成直後の select() や一覧取得のため、認証済みユーザーに閲覧を許可
CREATE POLICY "groups_select_all_auth"
ON groups FOR SELECT
TO authenticated
USING (true);

-- 更新: 所属メンバーのみ更新可能
CREATE POLICY "groups_update_members_only"
ON groups FOR UPDATE
TO authenticated
USING (
    id IN (SELECT get_my_group_ids())
);