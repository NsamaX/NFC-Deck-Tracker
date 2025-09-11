import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class SupabaseService {
  final SupabaseClient supabase;
  final String path = 'cards';

  SupabaseService({
    required this.supabase,
  });

  String? _getFilePathFromImageUrl(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 3 &&
          pathSegments[0] == 'storage' &&
          pathSegments[1] == 'v1' &&
          pathSegments[2] == 'object' &&
          pathSegments[3] == 'public' &&
          pathSegments[4] == path) {
        return pathSegments.sublist(5).join('/');
      }
      LoggerUtil.e('❌ Invalid Supabase image URL format: $imageUrl');
      return null;
    } catch (e) {
      LoggerUtil.e('❌ Error parsing image URL to file path: $e');
      return null;
    }
  }

  Future<String?> uploadImage({
    required String imagePath,
  }) async {
    if (!imagePath.contains('.')) {
      LoggerUtil.e('❌ Invalid image path (no extension): $imagePath');
      return null;
    }

    final file = File(imagePath);

    if (!file.existsSync()) {
      LoggerUtil.e('❌ File does not exist at path: $imagePath');
      return null;
    }

    try {
      final fileExt = imagePath.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final filePath = 'images/$fileName';

      final storageResponse = await supabase.storage.from(path).upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      if (storageResponse.isEmpty) {
        LoggerUtil.e('❌ Upload failed: Empty response from Supabase');
        return null;
      }

      final publicUrl = supabase.storage.from(path).getPublicUrl(filePath);
      LoggerUtil.i('📤 Uploaded image → $publicUrl');
      return publicUrl;
    } catch (e) {
      LoggerUtil.e('❌ Failed to upload image: $e');
      return null;
    }
  }

  Future<String?> updateImage({
    required String oldImageUrl,
    required String newImagePath,
  }) async {
    if (!newImagePath.contains('.')) {
      LoggerUtil.e('❌ Invalid new image path (no extension): $newImagePath');
      return null;
    }

    final newFile = File(newImagePath);

    if (!newFile.existsSync()) {
      LoggerUtil.e('❌ New file does not exist at path: $newImagePath');
      return null;
    }

    final filePathToUpdate = _getFilePathFromImageUrl(oldImageUrl);
    if (filePathToUpdate == null) {
      LoggerUtil.e('❌ Could not derive file path from oldImageUrl: $oldImageUrl');
      return null;
    }

    try {
      final storageResponse = await supabase.storage.from(path).update(
            filePathToUpdate,
            newFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      if (storageResponse.isEmpty) {
        LoggerUtil.e('❌ Update failed: Empty response from Supabase');
        return null;
      }

      final publicUrl = supabase.storage.from(path).getPublicUrl(filePathToUpdate);
      LoggerUtil.i('🔄 Updated image → $publicUrl');
      return publicUrl;
    } catch (e) {
      LoggerUtil.e('❌ Failed to update image: $e');
      return null;
    }
  }

  Future<bool> deleteImage({
    required List<String> imageUrls,
  }) async {
    if (imageUrls.isEmpty) {
      LoggerUtil.i('ℹ️ No image URLs provided for deletion.');
      return true;
    }

    final List<String> filePathsToDelete = [];
    for (final url in imageUrls) {
      final filePath = _getFilePathFromImageUrl(url);
      if (filePath != null) {
        filePathsToDelete.add(filePath);
      } else {
        LoggerUtil.i('⚠️ Skipping deletion for invalid URL: $url');
      }
    }

    if (filePathsToDelete.isEmpty) {
      LoggerUtil.i('ℹ️ No valid file paths derived from provided URLs for deletion.');
      return true;
    }

    try {
      await supabase.storage.from(path).remove(filePathsToDelete);
      LoggerUtil.i('🗑️ Deleted images: $filePathsToDelete');
      return true;
    } catch (e) {
      LoggerUtil.e('❌ Failed to delete images: $e');
      return false;
    }
  }
}
