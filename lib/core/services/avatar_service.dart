// MANUAL SETUP REQUIRED before running:
// 1. Supabase Dashboard → Storage → Create bucket named 'avatars' → set to Public
// 2. Storage → Policies → avatars bucket → add policies:
//    SELECT: true (public read)
//    INSERT: auth.uid()::text = (storage.foldername(name))[1]
//    UPDATE: auth.uid()::text = (storage.foldername(name))[1]
//    DELETE: auth.uid()::text = (storage.foldername(name))[1]
// 3. SQL Editor → run: ALTER TABLE public.profile ADD COLUMN IF NOT EXISTS avatar_url text;

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarService {
  const AvatarService._();

  static const String _bucket = 'avatars';

  /// Uploads an avatar image to Supabase Storage and updates the profile table.
  static Future<String> uploadAvatar(String userId, File imageFile) async {
    final storagePath = '$userId/avatar.jpg';

    // Upload to 'avatars' bucket, replacing existing
    await Supabase.instance.client.storage.from(_bucket).upload(
      storagePath,
      imageFile,
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );

    // Get the public URL
    final publicUrl = Supabase.instance.client.storage.from(_bucket).getPublicUrl(storagePath);

    // Update profile table
    await Supabase.instance.client
        .from('profile')
        .update({'avatar_url': publicUrl})
        .eq('id', userId);

    return publicUrl;
  }

  /// Returns the public URL for a user's avatar.
  static String getAvatarUrl(String userId) {
    return Supabase.instance.client.storage.from(_bucket).getPublicUrl('$userId/avatar.jpg');
  }
}
