import '../datasource/remote/upload_image.dart';

class UploadImageRepository {
  final UploadImageRemoteDatasource uploadImageRemoteDatasource;

  UploadImageRepository({
    required this.uploadImageRemoteDatasource,
  });

  Future<String?> upload({
    required String userId,
    required String imagePath,
  }) async {
    return await uploadImageRemoteDatasource.upload(userId: userId, imagePath: imagePath);
  }
}
