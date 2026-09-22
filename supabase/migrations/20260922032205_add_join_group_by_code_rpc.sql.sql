-- ====================================================
-- 招待コードによるグループ参加 RPC
-- ====================================================
CREATE OR REPLACE FUNCTION public.join_group_by_code(p_invitation_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_group_id UUID;
    v_existing_membership_id UUID;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- 招待コードに合致するグループを検索
    SELECT id INTO v_group_id
    FROM public.groups
    WHERE invitation_code = p_invitation_code;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid invitation code');
    END IF;

    -- すでに参加済みか確認
    SELECT id INTO v_existing_membership_id
    FROM public.groups_memberships
    WHERE group_id = v_group_id AND user_id = v_user_id;

    IF FOUND THEN
        RETURN jsonb_build_object('success', true, 'message', 'Already a member', 'group_id', v_group_id);
    END IF;

    -- 一般メンバー (role = 1) として追加
    INSERT INTO public.groups_memberships (group_id, user_id, role)
    VALUES (v_group_id, v_user_id, 1);

    RETURN jsonb_build_object('success', true, 'group_id', v_group_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.join_group_by_code(TEXT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.join_group_by_code(TEXT) FROM anon;