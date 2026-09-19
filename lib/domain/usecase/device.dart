import '../entity/selected_image.dart';
import '../repository/device.dart';

class DeviceUsecase {
  final DeviceRepository repository;
  DeviceUsecase(this.repository);
  Stream<bool> get connectivityChanges => repository.connectivityChanges;
  Future<String> appVersion() => repository.appVersion();
  Future<SelectedImage> selectCardImage() => repository.selectCardImage();
}
