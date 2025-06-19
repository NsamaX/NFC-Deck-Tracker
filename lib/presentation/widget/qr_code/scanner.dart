import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import '../../cubit/room.dart';
import '../../locale/localization.dart';

import '../app_bar/@default.dart';

class QRCodeScanner extends StatefulWidget {
  final RoomCubit roomCubit;

  QRCodeScanner({
    super.key,
    required this.roomCubit,
  });

  @override
  State<QRCodeScanner> createState() => _JoinRoomScannerPageState();
}

class _JoinRoomScannerPageState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        setState(() {
          result = scanData.code;
        });
        final List<String> playerIds = [
          locator<FirebaseAuth>().currentUser?.uid ?? 'me',
          result ?? '',
        ];
        if (playerIds[0] == playerIds[1] || playerIds.isEmpty) return;
        widget.roomCubit.createRoom(playerIds: playerIds);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: DefaultAppBar(menu: [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: locale.translate('page_join_room.app_bar'),
        ),
        AppBarMenuItem.empty(),
      ]),
      body: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 10,
              borderLength: 20,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          Positioned(
            bottom: 16,
            child: Text(
              locale.translate('page_join_room.tip'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
