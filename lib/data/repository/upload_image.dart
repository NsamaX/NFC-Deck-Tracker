import '../datasource/remote/upload_image.dart';

class UploadImageRepository {
  final UploadImageRemoteDatasource uploadImageRemoteDatasource;

  UploadImageRepository({
    required this.uploadImageRemoteDatasource,
  });

  Future<String?> uploadCardImage({
    required String userId,
    required String imagePath,
  }) async {
    return await uploadImageRemoteDatasource.uploadCardImage(userId: userId, imagePath: imagePath);
  }
}
