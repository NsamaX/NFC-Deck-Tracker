import '../datasource/remote/@supabase_service.dart';

class UpdateImageRepository {
  final SupabaseService supabaseService;

  UpdateImageRepository({
    required this.supabaseService,
  });

  Future<String?> update({
    required String oldImageUrl,
    required String newImagePath,
  }) async {
    return await supabaseService.updateImage(oldImageUrl: oldImageUrl, newImagePath: newImagePath);
  }
}
