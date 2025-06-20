import '@supabase_service.dart';

class UploadImageRemoteDatasource {
  final SupabaseService _supabaseService;

  UploadImageRemoteDatasource(this._supabaseService);

  Future<String?> upload({
    required String userId,
    required String imagePath,
  }) async {
    return await _supabaseService.uploadImage(
      userId: userId,
      imagePath: imagePath,
    );
  }
}
