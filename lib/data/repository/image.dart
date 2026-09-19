import '../../domain/repository/image.dart';
import '../datasource/remote/supabase_service.dart';

class ImageRepositoryImpl implements ImageRepository {
  final SupabaseService supabaseService;

  ImageRepositoryImpl({
    required this.supabaseService,
  });

  @override
  Future<bool> delete({
    required List<String> imageUrls,
  }) async {
    return await supabaseService.deleteImage(imageUrls: imageUrls);
  }

  @override
  Future<String?> update({
    required String oldImageUrl,
    required String newImagePath,
  }) async {
    return await supabaseService.updateImage(
        oldImageUrl: oldImageUrl, newImagePath: newImagePath);
  }

  @override
  Future<String?> upload({
    required String imagePath,
  }) async {
    return await supabaseService.uploadImage(imagePath: imagePath);
  }
}
