import '../datasource/remote/@supabase_service.dart';

class UploadImageRepository {
  final SupabaseService supabaseService;

  UploadImageRepository({
    required this.supabaseService,
  });

  Future<String?> upload({
    required String imagePath,
  }) async {
    return await supabaseService.uploadImage(imagePath: imagePath);
  }
}
