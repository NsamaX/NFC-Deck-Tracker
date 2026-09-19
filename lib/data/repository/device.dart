import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entity/selected_image.dart';
import '../../domain/repository/device.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  @override
  Stream<bool> get connectivityChanges =>
      Connectivity().onConnectivityChanged.map((results) =>
          results.any((result) => result != ConnectivityResult.none));

  @override
  Future<String> appVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  @override
  Future<SelectedImage> selectCardImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted)
      return const SelectedImage(status: ImageSelectionStatus.permissionDenied);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null)
      return const SelectedImage(status: ImageSelectionStatus.cancelled);
    final dir = await getApplicationDocumentsDirectory();
    final fileName = picked.path.split('/').last;
    final file = await File(picked.path).copy('${dir.path}/$fileName');
    return SelectedImage(
        status: ImageSelectionStatus.selected, path: file.path);
  }
}
