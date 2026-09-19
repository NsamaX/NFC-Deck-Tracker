abstract interface class ImageRepository {
  Future<bool> delete({
    required List<String> imageUrls,
  });

  Future<String?> update({
    required String oldImageUrl,
    required String newImagePath,
  });

  Future<String?> upload({
    required String imagePath,
  });
}
