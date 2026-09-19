enum ImageSelectionStatus { selected, cancelled, permissionDenied }

class SelectedImage {
  final ImageSelectionStatus status;
  final String? path;
  const SelectedImage({required this.status, this.path});
}
