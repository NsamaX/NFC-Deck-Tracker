import '../../dependencies.dart';
import '../../../domain/entity/selected_image.dart';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/card/bloc.dart';
import '../../locale/localization.dart';

class CardCustomImage extends StatelessWidget {
  const CardCustomImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CardBloc, CardState, String>(
      selector: (state) => state.card.imageUrl ?? '',
      builder: (_, imageUrl) {
        return _wrapWithTap(
          onTap: () => _pickImage(context),
          child: imageUrl.isNotEmpty
              ? _buildImage(imageUrl)
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

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: imageUrl.startsWith('http')
          ? Image.network(imageUrl, fit: BoxFit.cover, gaplessPlayback: true)
          : Image.file(File(imageUrl),
              fit: BoxFit.cover, gaplessPlayback: true),
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalization.of(context);

    return DottedBorder(
      color: theme.textTheme.bodySmall!.color!.withAlpha((0.2 * 255).toInt()),
      borderType: BorderType.RRect,
      radius: const Radius.circular(16.0),
      dashPattern: const [14.0, 24.0],
      strokeWidth: 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_rounded,
                size: 36.0, color: theme.iconTheme.color),
            const SizedBox(height: 8.0),
            Text(locale.translate('page_card_detail.upload_image'),
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final locale = AppLocalization.of(context);

    final selected =
        await PresentationScope.read(context).device.selectCardImage();
    if (!context.mounted) return;
    if (selected.status == ImageSelectionStatus.permissionDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.translate('permission.denied_photos'))),
      );
    } else if (selected.status == ImageSelectionStatus.selected) {
      context
          .read<CardBloc>()
          .add(SetCardImageUrlEvent(imageUrl: selected.path!));
    }
  }
}
