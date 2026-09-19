import '../entity/selected_image.dart';

abstract interface class DeviceRepository {
  Stream<bool> get connectivityChanges;
  Future<String> appVersion();
  Future<SelectedImage> selectCardImage();
}
