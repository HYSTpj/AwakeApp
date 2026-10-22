-- 1. 前後の空白類（半角スペース、タブ、改行、全角スペース等）を除去
UPDATE public.profiles
SET nickname = regexp_replace(regexp_replace(nickname, '^[[:space:]]+', ''), '[[:space:]]+$', '')
WHERE nickname IS NOT NULL;

-- 2. 空文字や空白類のみのレコードをフォールバック
UPDATE public.profiles
SET nickname = 'No Name'
WHERE nickname IS NULL OR nickname ~ '^[[:space:]]*$';

-- 3. 30文字を超えるものがあれば先頭30文字に切り詰める
UPDATE public.profiles
SET nickname = substring(nickname from 1 for 30)
WHERE char_length(nickname) > 30;

-- 4. 制約を追加
-- 条件:
-- ・空白類以外の文字が少なくとも1文字含まれていること（空白文字・タブ・改行のみを排除）
-- ・文字数全体が 1文字以上 30文字以下であること
ALTER TABLE public.profiles
ADD CONSTRAINT check_nickname_length
CHECK (
    nickname ~ '[^[:space:]]' 
    AND char_length(nickname) <= 30
);