import '../datasource/remote/@supabase_service.dart';

class DeleteImageRepository {
  final SupabaseService supabaseService;

  DeleteImageRepository({
    required this.supabaseService,
  });

  Future<bool> delete({
    required List<String> imageUrls,
  }) async {
    return await supabaseService.deleteImage(imageUrls: imageUrls);
  }
}
