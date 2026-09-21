-- ====================================================
-- ユーザー新規登録時に profiles を自動生成するトリガー
-- ====================================================

-- トリガー関数の定義
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
        0,
        0
    );
    RETURN NEW;
END;
$$;

-- auth.users に対するトリガー設定
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();