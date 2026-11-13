-- ====================================================
-- 1. 旧トリガー・不要関数のクリーンアップ（安全策）
-- ====================================================
DROP TRIGGER IF EXISTS trg_cleanup_user_storage ON auth.users;
DROP FUNCTION IF EXISTS public.cleanup_user_storage_on_delete();

-- ====================================================
-- 2. late-evidences バケットの INSERT / DELETE ポリシーを自身の UID に厳格制限
-- ====================================================
DROP POLICY IF EXISTS "late_evidences_insert" ON storage.objects;
CREATE POLICY "late_evidences_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'late-evidences'
    AND (name LIKE (auth.uid()::text || '/%'))
);

DROP POLICY IF EXISTS "late_evidences_delete" ON storage.objects;
CREATE POLICY "late_evidences_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'late-evidences'
    AND (name LIKE (auth.uid()::text || '/%'))
);

-- ====================================================
-- 3. アカウント削除用 RPC（孤児グループ削除 + ユーザー削除）
-- ====================================================
CREATE OR REPLACE FUNCTION public.delete_user()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_group_id UUID;
    v_admin_count INT;
    v_member_count INT;
    v_group_ids UUID[];
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- 所属グループの ID 配列を安全にメモリ上へ退避
    SELECT COALESCE(array_agg(group_id), ARRAY[]::UUID[])
    INTO v_group_ids
    FROM public.groups_memberships
    WHERE user_id = v_user_id;

    -- 各グループの孤児化防止クリーンアップ
    IF array_length(v_group_ids, 1) > 0 THEN
        FOREACH v_group_id IN ARRAY v_group_ids
        LOOP
            IF EXISTS (SELECT 1 FROM public.groups WHERE id = v_group_id) THEN
                SELECT 
                    COUNT(*) FILTER (WHERE role = 0),
                    COUNT(*)
                INTO v_admin_count, v_member_count
                FROM public.groups_memberships
                WHERE group_id = v_group_id;

                -- 唯一の管理者、またはメンバーが自分のみのグループは削除
                IF (v_admin_count = 1 AND EXISTS (
                    SELECT 1 FROM public.groups_memberships 
                    WHERE group_id = v_group_id AND user_id = v_user_id AND role = 0
                )) OR v_member_count <= 1 THEN
                    DELETE FROM public.groups WHERE id = v_group_id;
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- auth.users レコードの削除（profiles 連動 CASCADE）
    DELETE FROM auth.users WHERE id = v_user_id;
END;
$$;

-- 最小権限設定
REVOKE EXECUTE ON FUNCTION public.delete_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_user() TO authenticated;