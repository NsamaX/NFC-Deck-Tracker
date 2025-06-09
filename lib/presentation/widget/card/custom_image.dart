import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../cubit/card_cubit.dart';
import '../../locale/localization.dart';

class CardCustomImage extends StatelessWidget {
  final CardCubit cardCubit;

  const CardCustomImage({
    super.key,
    required this.cardCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CardCubit, CardState, String>(
      selector: (state) => state.card.imageUrl ?? '',
      builder: (_, imageUrl) {
        return _wrapWithTap(
          onTap: () => _pickImage(context),
          child: imageUrl.isNotEmpty
              ? _buildImage(imageFile: File(imageUrl))
              : _buildUploadPlaceholder(context),
        );
      },
    );
  }

  Widget _wrapWithTap({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: GestureDetector(onTap: onTap, child: child),
    );
  }

  Widget _buildImage({required File imageFile}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.file(imageFile, fit: BoxFit.cover, gaplessPlayback: true),
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalization.of(context);

    return DottedBorder(
      color: Colors.white.withAlpha((0.2 * 255).toInt()),
      borderType: BorderType.RRect,
      radius: const Radius.circular(16.0),
      dashPattern: const [14.0, 24.0],
      strokeWidth: 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_rounded, size: 36.0, color: Colors.grey),
            const SizedBox(height: 8.0),
            Text(locale.translate('page_card_detail.upload_image'), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final locale = AppLocalization.of(context);

    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.translate('permission.denied_photos'))),
      );
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final savedPath = await _saveImageToPermanentDirectory(picked.path);
    cardCubit.setCardImageUrl(imageUrl: savedPath);
  }

  Future<String> _saveImageToPermanentDirectory(String imagePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = imagePath.split('/').last;
    final newPath = '${dir.path}/$fileName';
    return File(imagePath).copy(newPath).then((f) => f.path);
  }
}
