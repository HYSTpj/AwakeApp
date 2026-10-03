-- avatars: upsert アップロード時、INSERT と同時に UPDATE 権限も要求されるため追加
-- （storage.objects への INSERT ... ON CONFLICT DO UPDATE は UPDATE ポリシーも必須）
CREATE POLICY "avatars_user_update" ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text)
WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
