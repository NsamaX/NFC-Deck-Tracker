import 'dart:io';

import '../../domain/repository/image.dart';
import '../../util/logger.dart';
import '../datasource/remote/supabase_service.dart';

class ImageRepositoryImpl implements ImageRepository {
  final SupabaseService supabaseService;

  ImageRepositoryImpl({
    required this.supabaseService,
  });

  static bool _isLocal(String path) =>
      path.isNotEmpty && !path.startsWith('http');

  @override
  Future<bool> delete({
    required List<String> imageUrls,
  }) async {
    final local = imageUrls.where(_isLocal).toList();
    final remote = imageUrls.where((u) => u.startsWith('http')).toList();
    for (final path in local) {
      await _deleteLocal(path);
    }
    if (remote.isEmpty) return true;
    return await supabaseService.deleteImage(imageUrls: remote);
  }

  @override
  Future<String?> update({
    required String oldImageUrl,
    required String newImagePath,
  }) async {
    final String? result;
    if (oldImageUrl.startsWith('http')) {
      result = await supabaseService.updateImage(
          oldImageUrl: oldImageUrl, newImagePath: newImagePath);
      if (result != null && result != newImagePath) {
        await _deleteLocal(newImagePath);
      }
    } else {
      result = await upload(imagePath: newImagePath);
    }
    if (result != null && _isLocal(oldImageUrl) && oldImageUrl != result) {
      await _deleteLocal(oldImageUrl);
    }
    return result;
  }

  @override
  Future<String?> upload({
    required String imagePath,
  }) async {
    final result = await supabaseService.uploadImage(imagePath: imagePath);
    if (result != null && result != imagePath) {
      await _deleteLocal(imagePath);
    }
    return result;
  }

  Future<void> _deleteLocal(String path) async {
    if (!_isLocal(path)) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (e) {
      LoggerUtil.e('Failed to delete local image "$path": $e');
    }
  }
}
