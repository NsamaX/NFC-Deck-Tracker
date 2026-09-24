import 'package:equatable/equatable.dart';

enum ImageSelectionStatus { selected, cancelled, permissionDenied }

class SelectedImage extends Equatable {
  final ImageSelectionStatus status;
  final String? path;
  const SelectedImage({required this.status, this.path});

  @override
  List<Object?> get props => [status, path];
}
