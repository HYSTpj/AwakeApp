-- アカウント削除時に自身の証拠写真を一覧取得できるようにする
DROP POLICY IF EXISTS "late_evidences_select" ON storage.objects;
CREATE POLICY "late_evidences_select"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'late-evidences'
    AND (name LIKE (auth.uid()::text || '/%'))
);
