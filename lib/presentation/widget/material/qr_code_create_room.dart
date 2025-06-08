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
    final String qrData = '{"roomId":"$roomId","userId":"$userId"}';

    return Center(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              spreadRadius: 1.0,
              blurRadius: 2.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
