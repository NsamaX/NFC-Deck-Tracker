import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class QRCodeCreateRoom extends StatelessWidget {
  final String userId;
  final String roomId = const Uuid().v4();

  QRCodeCreateRoom({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImageView(
        data: '{"roomId":"$roomId","userId":"$userId"}',
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
      ),
    );
  }
}
