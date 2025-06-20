import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class SupabaseService {
  final SupabaseClient supabase;

  SupabaseService({required this.supabase});

  Future<String?> uploadImage({
    required String userId,
    required String imagePath,
  }) async {
    if (!imagePath.contains('.')) {
      LoggerUtil.debugMessage('❌ Invalid image path (no extension): $imagePath');
      return null;
    }

    final file = File(imagePath);

    if (!file.existsSync()) {
      LoggerUtil.debugMessage('❌ File does not exist at path: $imagePath');
      return null;
    }

    try {
      final fileExt = imagePath.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final filePath = 'users/$userId/images/$fileName';

      final storageResponse = await supabase.storage.from('card-images').upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      if (storageResponse.isEmpty) {
        LoggerUtil.debugMessage('❌ Upload failed: Empty response from Supabase');
        return null;
      }

      final publicUrl = supabase.storage.from('card-images').getPublicUrl(filePath);
      LoggerUtil.debugMessage('📤 Uploaded image → $publicUrl');
      return publicUrl;
    } catch (e) {
      LoggerUtil.debugMessage('❌ Failed to upload image: $e');
      return null;
    }
  }
}
