import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

class QRCodeGeneretor extends StatelessWidget {
  QRCodeGeneretor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImageView(
        data: PresentationScope.read(context).userId,
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
      ),
    );
  }
}
