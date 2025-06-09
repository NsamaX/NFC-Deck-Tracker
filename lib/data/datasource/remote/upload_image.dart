import 'dart:io';

import '@firestore_service.dart';

class UploadImageRemoteDatasource {
  final FirestoreService _firestoreService;

  UploadImageRemoteDatasource(this._firestoreService);

  Future<String?> uploadCardImage({
    required String userId,
    required String imagePath,
  }) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      return null;
    }

    final imageUrl = await _firestoreService.uploadImage(
      userId: userId,
      imagePath: imagePath,
    );

    return imageUrl;
  }
}
